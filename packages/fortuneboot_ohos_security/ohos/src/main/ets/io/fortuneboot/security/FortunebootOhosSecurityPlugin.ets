import buffer from '@ohos.buffer';
import common from '@ohos.app.ability.common';
import cryptoFramework from '@ohos.security.cryptoFramework';
import dataPreferences from '@ohos.data.preferences';
import huks from '@ohos.security.huks';
import userAuth from '@ohos.userIAM.userAuth';
import {
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import MethodChannel, {
  MethodCallHandler,
  MethodResult,
} from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';

const CHANNEL_NAME: string = 'fortuneboot/ohos_security';
const PREFERENCES_NAME: string = 'fortuneboot_secure_app_lock';
const VERIFIER_KEY: string = 'fortune.app_lock.verifier';
const HUKS_KEY_ALIAS: string = 'fortuneboot.app_lock.aes_gcm';
const IV_LENGTH: number = 12;
const ASSOCIATED_DATA: Uint8Array = new Uint8Array([
  102, 111, 114, 116, 117, 110, 101, 98, 111, 111, 116,
]);

type StoredSecret = string;

export default class FortunebootOhosSecurityPlugin
  implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private context: common.Context | null = null;
  private preferences: dataPreferences.Preferences | null = null;
  private authenticationInProgress: boolean = false;

  getUniqueClassName(): string {
    return 'FortunebootOhosSecurityPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.context = binding.getApplicationContext();
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.preferences = null;
    this.context = null;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'readSecret') {
      this.readSecret(call, result);
      return;
    }
    if (call.method === 'writeSecret') {
      this.writeSecret(call, result);
      return;
    }
    if (call.method === 'deleteSecret') {
      this.deleteSecret(call, result);
      return;
    }
    if (call.method === 'isBiometricAvailable') {
      result.success(this.isBiometricAvailable());
      return;
    }
    if (call.method === 'authenticateBiometrics') {
      this.authenticateBiometrics(call, result);
      return;
    }
    result.notImplemented();
  }

  private async readSecret(call: MethodCall, result: MethodResult): Promise<void> {
    const key: string | null = this.readKey(call);
    if (key === null) {
      result.error('invalid_argument', 'Missing secret key', null);
      return;
    }
    try {
      const preferences: dataPreferences.Preferences = await this.getPreferences();
      const value: dataPreferences.ValueType = await preferences.get(key, '');
      if (typeof value !== 'string' || value.length === 0) {
        result.success(null);
        return;
      }
      result.success(await this.decrypt(value));
    } catch (_) {
      result.error('secure_storage_failed', 'Unable to read secure secret', null);
    }
  }

  private async writeSecret(call: MethodCall, result: MethodResult): Promise<void> {
    const key: string | null = this.readKey(call);
    const value: string | null = call.argument('value');
    if (key === null || value === null || value.length === 0) {
      result.error('invalid_argument', 'Missing secret payload', null);
      return;
    }
    try {
      const encryptedValue: StoredSecret = await this.encrypt(value);
      const preferences: dataPreferences.Preferences = await this.getPreferences();
      await preferences.put(key, encryptedValue);
      await preferences.flush();
      result.success(null);
    } catch (_) {
      result.error('secure_storage_failed', 'Unable to write secure secret', null);
    }
  }

  private async deleteSecret(call: MethodCall, result: MethodResult): Promise<void> {
    const key: string | null = this.readKey(call);
    if (key === null) {
      result.error('invalid_argument', 'Missing secret key', null);
      return;
    }
    try {
      const preferences: dataPreferences.Preferences = await this.getPreferences();
      await preferences.delete(key);
      await preferences.flush();
      result.success(null);
    } catch (_) {
      result.error('secure_storage_failed', 'Unable to delete secure secret', null);
    }
  }

  private readKey(call: MethodCall): string | null {
    const key: string | null = call.argument('key');
    return key === VERIFIER_KEY ? key : null;
  }

  private async getPreferences(): Promise<dataPreferences.Preferences> {
    if (this.preferences !== null) return this.preferences;
    if (this.context === null) throw new Error('Application context unavailable');
    this.preferences = await dataPreferences.getPreferences(this.context, PREFERENCES_NAME);
    return this.preferences;
  }

  private async encrypt(value: string): Promise<StoredSecret> {
    await this.ensureHuksKey();
    const nonce: Uint8Array = await this.createNonce();
    const options: huks.HuksOptions = {
      properties: this.cryptoProperties(huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT, nonce),
      inData: this.utf8Bytes(value),
    };
    const session: huks.HuksSessionHandle = await huks.initSession(HUKS_KEY_ALIAS, options);
    const encrypted: huks.HuksReturnResult = await huks.finishSession(session.handle, options);
    if (encrypted.outData === undefined) throw new Error('Encryption produced no data');
    const tag: Uint8Array = this.readAuthenticationTag(encrypted);
    return `v1:${buffer.from(nonce).toString('base64')}:${buffer.from(tag).toString('base64')}:${buffer.from(encrypted.outData).toString('base64')}`;
  }

  private async decrypt(payload: StoredSecret): Promise<string> {
    const parts: Array<string> = payload.split(':');
    if (parts.length !== 4 || parts[0] !== 'v1') throw new Error('Invalid secure payload');
    const nonce: Uint8Array = this.base64Bytes(parts[1]);
    const tag: Uint8Array = this.base64Bytes(parts[2]);
    const encrypted: Uint8Array = this.base64Bytes(parts[3]);
    if (nonce.length !== IV_LENGTH || tag.length !== 16 || encrypted.length === 0) {
      throw new Error('Invalid secure payload');
    }
    await this.ensureHuksKey();
    const options: huks.HuksOptions = {
      properties: this.cryptoProperties(
        huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT,
        nonce,
        tag,
      ),
      inData: encrypted,
    };
    const session: huks.HuksSessionHandle = await huks.initSession(HUKS_KEY_ALIAS, options);
    const decrypted: huks.HuksReturnResult = await huks.finishSession(session.handle, options);
    if (decrypted.outData === undefined) throw new Error('Decryption produced no data');
    return buffer.from(decrypted.outData).toString();
  }

  private utf8Bytes(value: string): Uint8Array {
    const encoded: buffer.Buffer = buffer.from(value);
    return new Uint8Array(encoded.buffer, encoded.byteOffset, encoded.length);
  }

  private base64Bytes(value: string): Uint8Array {
    const decoded: buffer.Buffer = buffer.from(value, 'base64');
    return new Uint8Array(decoded.buffer, decoded.byteOffset, decoded.length);
  }

  private readAuthenticationTag(result: huks.HuksReturnResult): Uint8Array {
    const properties: Array<huks.HuksParam> = result.properties ?? [];
    for (let index: number = 0; index < properties.length; index++) {
      const property: huks.HuksParam = properties[index];
      if (property.tag === huks.HuksTag.HUKS_TAG_AE_TAG && property.value instanceof Uint8Array) {
        if (property.value.length === 16) return property.value;
      }
    }
    throw new Error('Encryption produced no authentication tag');
  }

  private async ensureHuksKey(): Promise<void> {
    const properties: Array<huks.HuksParam> = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
          huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT,
      },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: 256 },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_GCM },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE },
    ];
    const options: huks.HuksOptions = { properties: properties };
    if (!await huks.isKeyItemExist(HUKS_KEY_ALIAS, options)) {
      await huks.generateKeyItem(HUKS_KEY_ALIAS, options);
    }
  }

  private cryptoProperties(
    purpose: huks.HuksKeyPurpose,
    nonce: Uint8Array,
    authenticationTag?: Uint8Array,
  ): Array<huks.HuksParam> {
    const properties: Array<huks.HuksParam> = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: purpose },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: 256 },
      { tag: huks.HuksTag.HUKS_TAG_BLOCK_MODE, value: huks.HuksCipherMode.HUKS_MODE_GCM },
      { tag: huks.HuksTag.HUKS_TAG_PADDING, value: huks.HuksKeyPadding.HUKS_PADDING_NONE },
      { tag: huks.HuksTag.HUKS_TAG_NONCE, value: nonce },
      { tag: huks.HuksTag.HUKS_TAG_ASSOCIATED_DATA, value: ASSOCIATED_DATA },
    ];
    if (authenticationTag !== undefined) {
      properties.push({ tag: huks.HuksTag.HUKS_TAG_AE_TAG, value: authenticationTag });
    }
    return properties;
  }


  private async createNonce(): Promise<Uint8Array> {
    const random: cryptoFramework.Random = cryptoFramework.createRandom();
    const nonce: cryptoFramework.DataBlob = await random.generateRandom(IV_LENGTH);
    return nonce.data;
  }

  private isBiometricAvailable(): boolean {
    return this.isAuthTypeAvailable(userAuth.UserAuthType.FINGERPRINT) ||
      this.isAuthTypeAvailable(userAuth.UserAuthType.FACE);
  }

  private isAuthTypeAvailable(authType: userAuth.UserAuthType): boolean {
    try {
      userAuth.getAvailableStatus(authType, userAuth.AuthTrustLevel.ATL1);
      return true;
    } catch (_) {
      return false;
    }
  }

  private authenticateBiometrics(call: MethodCall, result: MethodResult): void {
    if (this.authenticationInProgress || !this.isBiometricAvailable()) {
      result.success(this.authenticationInProgress ? 'failed' : 'unavailable');
      return;
    }
    const authParam: userAuth.AuthParam = {
      challenge: cryptoFramework.createRandom().generateRandomSync(16).data,
      authType: [userAuth.UserAuthType.FINGERPRINT, userAuth.UserAuthType.FACE],
      authTrustLevel: userAuth.AuthTrustLevel.ATL1,
    };
    const localizedReason: string | null = call.argument('localizedReason');
    const title: string = localizedReason !== null && localizedReason.length > 0
      ? localizedReason
      : 'Verify your identity to unlock FortuneBoot';
    const widgetParam: userAuth.WidgetParam = { title };
    try {
      const instance: userAuth.UserAuthInstance = userAuth.getUserAuthInstance(
        authParam,
        widgetParam,
      );
      this.authenticationInProgress = true;
      instance.on('result', {
        onResult: (authResult: userAuth.UserAuthResult): void => {
          this.authenticationInProgress = false;
          if (authResult.result === userAuth.UserAuthResultCode.SUCCESS) {
            result.success('authenticated');
          } else if (
            authResult.result === userAuth.UserAuthResultCode.CANCELED ||
            authResult.result === userAuth.UserAuthResultCode.CANCELED_FROM_WIDGET ||
            authResult.result === userAuth.UserAuthResultCode.TIMEOUT
          ) {
            result.success('cancelled');
          } else if (
            authResult.result === userAuth.UserAuthResultCode.NOT_ENROLLED ||
            authResult.result === userAuth.UserAuthResultCode.TYPE_NOT_SUPPORT
          ) {
            result.success('unavailable');
          } else {
            result.success('failed');
          }
        },
      });
      instance.start();
    } catch (_) {
      this.authenticationInProgress = false;
      result.success('failed');
    }
  }
}
