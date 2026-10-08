import buffer from '@ohos.buffer';
import common from '@ohos.app.ability.common';
import cryptoFramework from '@ohos.security.cryptoFramework';
import dataPreferences from '@ohos.data.preferences';
import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import huks from '@ohos.security.huks';
import picker from '@ohos.file.picker';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import userAuth from '@ohos.userIAM.userAuth';
import window from '@ohos.window';
import {
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import FlutterManager from '@ohos/flutter_ohos/src/main/ets/embedding/ohos/FlutterManager';
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

class ScreenCaptureWindowController {
  private mainWindow: window.Window | null = null;
  private protectionEnabled: boolean = true;

  async bind(mainWindow: window.Window): Promise<void> {
    this.mainWindow = mainWindow;
    await this.applyProtection();
  }

  async setScreenCaptureAllowed(allowed: boolean): Promise<void> {
    const previousProtectionEnabled: boolean = this.protectionEnabled;
    this.protectionEnabled = !allowed;
    try {
      await this.applyProtection();
    } catch (_) {
      this.protectionEnabled = previousProtectionEnabled;
      throw new Error('Unable to update screen capture protection');
    }
  }

  async reapplyProtection(): Promise<void> {
    await this.applyProtection();
  }

  private async resolveMainWindow(): Promise<window.Window> {
    if (this.mainWindow !== null) {
      return this.mainWindow;
    }
    try {
      const abilityContext: common.UIAbilityContext =
        FlutterManager.getInstance().getUIAbility().context as common.UIAbilityContext;
      const resolved: window.Window = await window.getLastWindow(abilityContext);
      this.mainWindow = resolved;
      return resolved;
    } catch (_) {
      throw new Error('Main window unavailable');
    }
  }

  private async applyProtection(): Promise<void> {
    const targetWindow: window.Window = await this.resolveMainWindow();
    await targetWindow.setWindowPrivacyMode(this.protectionEnabled);
  }
}

const screenCaptureWindowController: ScreenCaptureWindowController =
  new ScreenCaptureWindowController();

export function bindScreenCaptureWindow(mainWindow: window.Window): void {
  screenCaptureWindowController.bind(mainWindow).catch((): void => {
    console.error('Unable to enable screen capture protection');
  });
}

export function reapplyScreenCaptureProtection(): void {
  screenCaptureWindowController.reapplyProtection().catch((): void => {
    console.error('Unable to reapply screen capture protection');
  });
}

type StoredSecret = string;

interface CipherAndTag {
  cipher: Uint8Array;
  tag: Uint8Array;
}

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
    if (call.method === 'isBiometricTypeAvailable') {
      result.success(this.isBiometricTypeAvailable(call));
      return;
    }
    if (call.method === 'authenticateBiometrics') {
      this.authenticateBiometrics(call, result);
      return;
    }
    if (call.method === 'setScreenCaptureAllowed') {
      this.setScreenCaptureAllowed(call, result);
      return;
    }
    if (call.method === 'saveImageToGallery') {
      this.saveImageToGallery(call, result);
      return;
    }
    if (call.method === 'saveDocument') {
      this.saveDocument(call, result);
      return;
    }
    result.notImplemented();
  }

  private async setScreenCaptureAllowed(
    call: MethodCall,
    result: MethodResult,
  ): Promise<void> {
    const allowed: boolean | null = call.argument('allowed');
    if (allowed === null) {
      result.error('invalid_argument', 'Missing allowed value', null);
      return;
    }
    try {
      await screenCaptureWindowController.setScreenCaptureAllowed(allowed);
      result.success(null);
    } catch (_) {
      result.error(
        'screen_capture_protection_failed',
        'Unable to update screen capture protection',
        null,
      );
    }
  }

  private async saveDocument(
    call: MethodCall,
    result: MethodResult,
  ): Promise<void> {
    const bytes: Uint8Array | null = this.readBytes(call.argument('bytes'));
    const fileName: string | null = call.argument('fileName');
    if (bytes === null || bytes.length === 0 || fileName === null || fileName.length === 0) {
      result.error('invalid_argument', 'Missing document payload', null);
      return;
    }

    try {
      const safeName: string = this.sanitizeFileName(fileName);
      const extension: string = this.fileExtension(safeName, 'xlsx');
      const documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [safeName];
      documentSaveOptions.fileSuffixChoices = [
        `Excel|.${extension}`,
        `.${extension}`,
      ];

      const documentViewPicker: picker.DocumentViewPicker =
        new picker.DocumentViewPicker();
      const uris: Array<string> = await documentViewPicker.save(documentSaveOptions);
      if (uris.length === 0) {
        result.success('cancelled');
        return;
      }

      const destFile: fileIo.File = fileIo.openSync(
        uris[0],
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE,
      );
      try {
        const payload: ArrayBuffer = bytes.buffer.slice(
          bytes.byteOffset,
          bytes.byteOffset + bytes.byteLength,
        );
        fileIo.writeSync(destFile.fd, payload);
      } finally {
        fileIo.closeSync(destFile);
      }
      result.success('saved');
    } catch (_) {
      result.error('document_save_failed', 'Unable to save document', null);
    }
  }

  private async saveImageToGallery(
    call: MethodCall,
    result: MethodResult,
  ): Promise<void> {
    const bytes: Uint8Array | null = this.readBytes(call.argument('bytes'));
    const fileName: string | null = call.argument('fileName');
    if (bytes === null || bytes.length === 0 || fileName === null || fileName.length === 0) {
      result.error('invalid_argument', 'Missing image payload', null);
      return;
    }

    let cachePath: string | null = null;
    try {
      const abilityContext: common.UIAbilityContext =
        FlutterManager.getInstance().getUIAbility().context as common.UIAbilityContext;
      const extension: string = this.fileExtension(fileName, 'jpg');
      const title: string = this.sanitizeTitle(this.stripExtension(fileName));
      cachePath = `${abilityContext.cacheDir}/${title}_${Date.now()}.${extension}`;

      const cacheFile: fileIo.File = fileIo.openSync(
        cachePath,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE,
      );
      try {
        const payload: ArrayBuffer = bytes.buffer.slice(
          bytes.byteOffset,
          bytes.byteOffset + bytes.byteLength,
        );
        fileIo.writeSync(cacheFile.fd, payload);
      } finally {
        fileIo.closeSync(cacheFile);
      }

      const srcUri: string = fileUri.getUriFromPath(cachePath);
      const helper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(abilityContext);
      const configs: Array<photoAccessHelper.PhotoCreationConfig> = [{
        title: title,
        fileNameExtension: extension,
        photoType: photoAccessHelper.PhotoType.IMAGE,
      }];
      const destUris: Array<string> = await helper.showAssetsCreationDialog(
        [srcUri],
        configs,
      );
      if (destUris.length === 0) {
        result.success(false);
        return;
      }

      const srcFile: fileIo.File = fileIo.openSync(cachePath, fileIo.OpenMode.READ_ONLY);
      const destFile: fileIo.File = fileIo.openSync(
        destUris[0],
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE,
      );
      try {
        await fileIo.copyFile(srcFile.fd, destFile.fd);
      } finally {
        fileIo.closeSync(srcFile);
        fileIo.closeSync(destFile);
      }
      result.success(true);
    } catch (_) {
      result.error('image_save_failed', 'Unable to save image to gallery', null);
    } finally {
      if (cachePath !== null) {
        try {
          fileIo.unlinkSync(cachePath);
        } catch (_) {
          // Best-effort cleanup of the sandbox cache file.
        }
      }
    }
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
      if (value.startsWith('fallback:')) {
        result.success(value.substring('fallback:'.length));
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
      const preferences: dataPreferences.Preferences = await this.getPreferences();
      let storedValue: StoredSecret;
      try {
        storedValue = await this.encrypt(value);
      } catch (_) {
        // Verifier 本身已是 PBKDF2 摘要；HUKS 不可用时降级到本地 preferences，避免应用锁无法开启。
        storedValue = `fallback:${value}`;
      }
      await preferences.put(key, storedValue);
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
    const initOptions: huks.HuksOptions = {
      properties: this.cryptoProperties(huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT, nonce),
    };
    const session: huks.HuksSessionHandle = await huks.initSession(HUKS_KEY_ALIAS, initOptions);
    const finishOptions: huks.HuksOptions = {
      properties: this.cryptoProperties(huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT, nonce),
      inData: this.utf8Bytes(value),
    };
    const encrypted: huks.HuksReturnResult = await huks.finishSession(
      session.handle,
      finishOptions,
    );
    if (encrypted.outData === undefined) throw new Error('Encryption produced no data');
    const split: CipherAndTag = this.splitCipherAndTag(encrypted);
    return `v1:${buffer.from(nonce).toString('base64')}:${buffer.from(split.tag).toString('base64')}:${buffer.from(split.cipher).toString('base64')}`;
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
    const initOptions: huks.HuksOptions = {
      properties: this.cryptoProperties(
        huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT,
        nonce,
        tag,
      ),
    };
    const session: huks.HuksSessionHandle = await huks.initSession(
      HUKS_KEY_ALIAS,
      initOptions,
    );
    // 部分机型要求密文后直接拼接 AE tag。
    const cipherWithTag: Uint8Array = new Uint8Array(encrypted.length + tag.length);
    cipherWithTag.set(encrypted, 0);
    cipherWithTag.set(tag, encrypted.length);
    const finishOptions: huks.HuksOptions = {
      properties: this.cryptoProperties(
        huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT,
        nonce,
        tag,
      ),
      inData: cipherWithTag,
    };
    try {
      const decrypted: huks.HuksReturnResult = await huks.finishSession(
        session.handle,
        finishOptions,
      );
      if (decrypted.outData === undefined) throw new Error('Decryption produced no data');
      return buffer.from(decrypted.outData).toString();
    } catch (_) {
      // 回退：仅传密文，tag 走 HUKS_TAG_AE_TAG。
      const retrySession: huks.HuksSessionHandle = await huks.initSession(
        HUKS_KEY_ALIAS,
        initOptions,
      );
      const retryOptions: huks.HuksOptions = {
        properties: this.cryptoProperties(
          huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT,
          nonce,
          tag,
        ),
        inData: encrypted,
      };
      const decrypted: huks.HuksReturnResult = await huks.finishSession(
        retrySession.handle,
        retryOptions,
      );
      if (decrypted.outData === undefined) throw new Error('Decryption produced no data');
      return buffer.from(decrypted.outData).toString();
    }
  }

  private utf8Bytes(value: string): Uint8Array {
    const encoded: buffer.Buffer = buffer.from(value);
    return new Uint8Array(encoded.buffer, encoded.byteOffset, encoded.length);
  }

  private base64Bytes(value: string): Uint8Array {
    const decoded: buffer.Buffer = buffer.from(value, 'base64');
    return new Uint8Array(decoded.buffer, decoded.byteOffset, decoded.length);
  }

  private splitCipherAndTag(result: huks.HuksReturnResult): CipherAndTag {
    const outData: Uint8Array | undefined = result.outData;
    if (outData === undefined || outData.length === 0) {
      throw new Error('Encryption produced no data');
    }
    const properties: Array<huks.HuksParam> = result.properties ?? [];
    for (let index: number = 0; index < properties.length; index++) {
      const property: huks.HuksParam = properties[index];
      if (property.tag === huks.HuksTag.HUKS_TAG_AE_TAG && property.value instanceof Uint8Array) {
        if (property.value.length === 16) {
          return { cipher: outData, tag: property.value };
        }
      }
    }
    // 多数机型把 16 字节 AE tag 追加在密文末尾。
    if (outData.length > 16) {
      return {
        cipher: outData.slice(0, outData.length - 16),
        tag: outData.slice(outData.length - 16),
      };
    }
    throw new Error('Encryption produced no authentication tag');
  }

  private async ensureHuksKey(): Promise<void> {
    const keySize: number = huks.HuksKeySize.HUKS_AES_KEY_SIZE_256;
    const properties: Array<huks.HuksParam> = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      {
        tag: huks.HuksTag.HUKS_TAG_PURPOSE,
        value: huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_ENCRYPT |
          huks.HuksKeyPurpose.HUKS_KEY_PURPOSE_DECRYPT,
      },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: keySize },
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
    const keySize: number = huks.HuksKeySize.HUKS_AES_KEY_SIZE_256;
    const properties: Array<huks.HuksParam> = [
      { tag: huks.HuksTag.HUKS_TAG_ALGORITHM, value: huks.HuksKeyAlg.HUKS_ALG_AES },
      { tag: huks.HuksTag.HUKS_TAG_PURPOSE, value: purpose },
      { tag: huks.HuksTag.HUKS_TAG_KEY_SIZE, value: keySize },
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
    return this.availableAuthTypes().length > 0;
  }

  private isBiometricTypeAvailable(call: MethodCall): boolean {
    const type: Object | null = call.argument('type');
    if (type === 'face') {
      return this.isAuthTypeAvailable(userAuth.UserAuthType.FACE);
    }
    if (type === 'fingerprint') {
      return this.isAuthTypeAvailable(userAuth.UserAuthType.FINGERPRINT);
    }
    return false;
  }

  private availableAuthTypes(preferredType?: string | null): Array<userAuth.UserAuthType> {
    const fingerprintAvailable: boolean =
      this.isAuthTypeAvailable(userAuth.UserAuthType.FINGERPRINT);
    const faceAvailable: boolean =
      this.isAuthTypeAvailable(userAuth.UserAuthType.FACE);
    if (preferredType === 'face') {
      return faceAvailable ? [userAuth.UserAuthType.FACE] : [];
    }
    if (preferredType === 'fingerprint') {
      return fingerprintAvailable ? [userAuth.UserAuthType.FINGERPRINT] : [];
    }
    const types: Array<userAuth.UserAuthType> = [];
    if (fingerprintAvailable) {
      types.push(userAuth.UserAuthType.FINGERPRINT);
    }
    if (faceAvailable) {
      types.push(userAuth.UserAuthType.FACE);
    }
    return types;
  }

  private isAuthTypeAvailable(authType: userAuth.UserAuthType): boolean {
    try {
      userAuth.getAvailableStatus(authType, userAuth.AuthTrustLevel.ATL1);
      return true;
    } catch (_) {
      return false;
    }
  }

  private mapAuthResult(code: number): string {
    // SUCCESS = 12500000；部分文档/机型成功回 0。
    if (
      code === userAuth.UserAuthResultCode.SUCCESS ||
      code === 12500000 ||
      code === 0
    ) {
      return 'authenticated';
    }
    if (
      code === userAuth.UserAuthResultCode.CANCELED ||
      code === userAuth.UserAuthResultCode.CANCELED_FROM_WIDGET ||
      code === userAuth.UserAuthResultCode.TIMEOUT ||
      code === 12500003 ||
      code === 12500004 ||
      code === 12500011
    ) {
      return 'cancelled';
    }
    if (
      code === userAuth.UserAuthResultCode.NOT_ENROLLED ||
      code === userAuth.UserAuthResultCode.TYPE_NOT_SUPPORT ||
      code === userAuth.UserAuthResultCode.TRUST_LEVEL_NOT_SUPPORT ||
      code === userAuth.UserAuthResultCode.BUSY ||
      code === userAuth.UserAuthResultCode.LOCKED ||
      code === 12500005 ||
      code === 12500006 ||
      code === 12500007 ||
      code === 12500009 ||
      code === 12500010
    ) {
      // 忙/锁定/未录入等：系统控件通常未真正完成一次识别，不应提示「未通过」。
      return 'unavailable';
    }
    // 仅 FAIL（12500001）等表示用户已看到控件但识别未通过。
    if (code === userAuth.UserAuthResultCode.FAIL || code === 12500001) {
      return 'failed';
    }
    return 'unavailable';
  }

  private authenticateBiometrics(call: MethodCall, result: MethodResult): void {
    // 上次 start 未回调时会卡死 in-progress，导致再次点击直接 failed 且不弹窗。
    this.authenticationInProgress = false;

    const preferredTypeArg: Object | null = call.argument('preferredType');
    const preferredType: string | null =
      typeof preferredTypeArg === 'string' ? preferredTypeArg : null;
    const authTypes: Array<userAuth.UserAuthType> =
      this.availableAuthTypes(preferredType);
    if (authTypes.length === 0) {
      result.success('unavailable');
      return;
    }

    let challenge: Uint8Array = new Uint8Array(0);
    try {
      const generated: Uint8Array =
        cryptoFramework.createRandom().generateRandomSync(16).data;
      if (generated !== undefined && generated.length > 0) {
        challenge = generated;
      }
    } catch (_) {
      challenge = new Uint8Array(0);
    }

    const localizedReason: Object | null = call.argument('localizedReason');
    const title: string =
      typeof localizedReason === 'string' && localizedReason.length > 0
        ? localizedReason
        : 'Verify your identity to unlock FortuneBoot';

    // 逐个类型尝试：避免多类型组合在部分机型上 getUserAuthInstance/start 直接失败且不弹窗。
    for (let index = 0; index < authTypes.length; index++) {
      const started: boolean = this.startAuthForType(
        authTypes[index],
        challenge,
        title,
        result,
        index === authTypes.length - 1,
      );
      if (started) {
        return;
      }
    }
    result.success('unavailable');
  }

  private startAuthForType(
    authType: userAuth.UserAuthType,
    challenge: Uint8Array,
    title: string,
    result: MethodResult,
    isLastType: boolean,
  ): boolean {
    const authParam: userAuth.AuthParam = {
      challenge: challenge,
      authType: [authType],
      authTrustLevel: userAuth.AuthTrustLevel.ATL1,
    };
    const widgetParam: userAuth.WidgetParam = { title };
    try {
      const instance: userAuth.UserAuthInstance = userAuth.getUserAuthInstance(
        authParam,
        widgetParam,
      );
      let completed: boolean = false;
      const complete = (status: string): void => {
        if (completed) {
          return;
        }
        completed = true;
        this.authenticationInProgress = false;
        result.success(status);
      };

      this.authenticationInProgress = true;
      instance.on('result', {
        onResult: (authResult: userAuth.UserAuthResult): void => {
          try {
            instance.off('result');
          } catch (_) {
            // ignore
          }
          if (authResult.token !== undefined && authResult.token.length > 0) {
            complete('authenticated');
            return;
          }
          complete(this.mapAuthResult(Number(authResult.result)));
        },
      });
      try {
        instance.start();
        return true;
      } catch (_) {
        this.authenticationInProgress = false;
        try {
          instance.off('result');
        } catch (__) {
          // ignore
        }
        if (isLastType) {
          complete('unavailable');
          return true;
        }
        return false;
      }
    } catch (_) {
      this.authenticationInProgress = false;
      if (isLastType) {
        result.success('unavailable');
        return true;
      }
      return false;
    }
  }

  private readBytes(value: Object | null): Uint8Array | null {
    if (value === null) {
      return null;
    }
    if (value instanceof Uint8Array) {
      return value;
    }
    return null;
  }

  private fileExtension(fileName: string, fallback: string): string {
    const dot: number = fileName.lastIndexOf('.');
    if (dot <= 0 || dot + 1 >= fileName.length) {
      return fallback;
    }
    const extension: string = fileName.substring(dot + 1).toLowerCase();
    if (extension === 'jpeg') {
      return 'jpg';
    }
    if (extension.length === 0) {
      return fallback;
    }
    return extension;
  }

  private stripExtension(fileName: string): string {
    const slash: number = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
    const baseName: string = slash >= 0 ? fileName.substring(slash + 1) : fileName;
    const dot: number = baseName.lastIndexOf('.');
    if (dot <= 0) {
      return baseName;
    }
    return baseName.substring(0, dot);
  }

  private sanitizeTitle(title: string): string {
    return this.sanitizeFileName(title);
  }

  private sanitizeFileName(fileName: string): string {
    const slash: number = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
    const baseName: string = slash >= 0 ? fileName.substring(slash + 1) : fileName;
    const invalid: string = '\\/:*?"\'`<>|{}[]';
    let cleaned: string = '';
    for (let index = 0; index < baseName.length; index++) {
      const character: string = baseName.charAt(index);
      cleaned += invalid.indexOf(character) >= 0 ? '_' : character;
    }
    cleaned = cleaned.trim();
    if (cleaned.length === 0) {
      return `fortuneboot_${Date.now()}.xlsx`;
    }
    if (cleaned.length > 80) {
      const extension: string = this.fileExtension(cleaned, 'xlsx');
      const stem: string = this.stripExtension(cleaned);
      const truncatedStem: string = stem.substring(0, Math.max(1, 80 - extension.length - 1));
      return `${truncatedStem}.${extension}`;
    }
    return cleaned;
  }
}
