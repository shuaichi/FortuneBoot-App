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
          // 部分机型/文档示例 UserAuth 成功时回 0；与 SUCCESS 一并视为认证通过。
          if (
            authResult.result === userAuth.UserAuthResultCode.SUCCESS ||
            authResult.result === 0
          ) {
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
