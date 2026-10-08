import common from '@ohos.app.ability.common';
import cryptoFramework from '@ohos.security.cryptoFramework';
import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import picker from '@ohos.file.picker';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import window from '@ohos.window';
import { BusinessError } from '@kit.BasicServicesKit';
import { userAuth } from '@kit.UserAuthenticationKit';
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
const APP_LOCK_CHANNEL_NAME: string = 'fortuneboot/app_lock';
/** UserAuthResultCode.SUCCESS；部分机型/文档示例也会回 0。 */
const AUTH_SUCCESS_CODE: number = 12500000;

/** 与 Dart Map 对齐；用 class 保证 MethodChannel 可序列化。 */
class AppLockAvailabilityPayload {
  face: boolean = false;
  fingerprint: boolean = false;
}

/** 用 number 回传结果（1/0），避免鸿蒙 MethodChannel 对裸 bool 编解码丢值。 */
class AppLockAuthReplyPayload {
  ok: number = 0;
  code: number = -1;
}

/** 与 Android MainActivity 的 fortuneboot/app_lock 通道对齐。 */
class AppLockAuthController {
  private authInstance: userAuth.UserAuthInstance | null = null;
  private pending: MethodResult | null = null;
  private startToken: number = 0;

  availability(): AppLockAvailabilityPayload {
    const payload: AppLockAvailabilityPayload = new AppLockAvailabilityPayload();
    payload.face = this.isAvailable(userAuth.UserAuthType.FACE);
    payload.fingerprint = this.isAvailable(userAuth.UserAuthType.FINGERPRINT);
    return payload;
  }

  authenticate(method: string, reason: string, result: MethodResult): void {
    // 仅作废上一次等待，避免把本次 result 提前回 false。
    this.invalidatePreviousAuth();
    const normalized: string = method.trim().toLowerCase();
    const authType: userAuth.UserAuthType = normalized === 'fingerprint'
      ? userAuth.UserAuthType.FINGERPRINT
      : userAuth.UserAuthType.FACE;
    const trustLevel: userAuth.AuthTrustLevel | null = this.resolveTrustLevel(authType);
    if (trustLevel === null) {
      console.error(`app_lock authenticate unavailable for method=${method}`);
      const denied: AppLockAuthReplyPayload = new AppLockAuthReplyPayload();
      denied.ok = 0;
      denied.code = 12500005;
      result.success(denied);
      return;
    }

    const token: number = ++this.startToken;
    this.pending = result;
    try {
      const challenge: Uint8Array = this.createChallenge();
      const types: Array<userAuth.UserAuthType> = [authType];
      const authParam: userAuth.AuthParam = {
        challenge: challenge,
        authType: types,
        authTrustLevel: trustLevel,
      };
      const title: string = reason.length > 0 ? reason : '请验证身份';
      const widgetParam: userAuth.WidgetParam = {
        title: title,
      };
      const instance: userAuth.UserAuthInstance =
        userAuth.getUserAuthInstance(authParam, widgetParam);
      this.authInstance = instance;
      const controller: AppLockAuthController = this;
      // 必须用闭包，不能用 class 方法：系统回调不会绑定 this，否则会报
      // "Cannot read property controller of undefined"。
      const listener: userAuth.IAuthCallback = {
        onResult: (authResult: userAuth.UserAuthResult): void => {
          try {
            instance.off('result');
          } catch (_) {
            // ignore
          }
          const code: number = Number(authResult.result);
          const hasToken: boolean =
            authResult.token !== undefined &&
            authResult.token !== null &&
            authResult.token.length > 0;
          const ok: boolean =
            hasToken ||
            code === userAuth.UserAuthResultCode.SUCCESS ||
            code === AUTH_SUCCESS_CODE ||
            code === 0;
          console.info(
            `app_lock onResult code=${code} hasToken=${hasToken} ok=${ok}`,
          );
          controller.finishPending(ok, code, token);
        },
      };
      instance.on('result', listener);
      // Flutter 弹层关闭动画未结束时立刻 start，系统控件常被直接取消。
      setTimeout((): void => {
        if (token !== this.startToken || this.pending === null) {
          return;
        }
        try {
          instance.start();
        } catch (error) {
          const err: BusinessError = error as BusinessError;
          console.error(
            `app_lock start failed: ${err?.code} ${err?.message}`,
          );
          this.finishPending(false, err?.code ?? -1, token);
        }
      }, 320);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      console.error(
        `app_lock authenticate failed: ${err?.code} ${err?.message}`,
      );
      this.finishPending(false, err?.code ?? -1, token);
    }
  }

  cancel(): void {
    this.invalidatePreviousAuth();
  }

  private invalidatePreviousAuth(): void {
    this.startToken++;
    const oldInstance: userAuth.UserAuthInstance | null = this.authInstance;
    this.authInstance = null;
    const oldPending: MethodResult | null = this.pending;
    this.pending = null;
    if (oldPending !== null) {
      const payload: AppLockAuthReplyPayload = new AppLockAuthReplyPayload();
      payload.ok = 0;
      payload.code = 12500003;
      oldPending.success(payload);
    }
    if (oldInstance !== null) {
      try {
        oldInstance.cancel();
      } catch (_) {
        // ignore
      }
    }
  }

  private createChallenge(): Uint8Array {
    try {
      const rand = cryptoFramework.createRandom();
      const data: Uint8Array | undefined =
        rand?.generateRandomSync(16)?.data;
      if (data !== undefined && data.length > 0) {
        return data;
      }
    } catch (_) {
      // fall through
    }
    return new Uint8Array(16);
  }

  private isAvailable(authType: userAuth.UserAuthType): boolean {
    return this.resolveTrustLevel(authType) !== null;
  }

  private resolveTrustLevel(
    authType: userAuth.UserAuthType,
  ): userAuth.AuthTrustLevel | null {
    // 应用锁优先 ATL1，兼容更多机型的 2D 面容/指纹。
    const levels: Array<userAuth.AuthTrustLevel> = [
      userAuth.AuthTrustLevel.ATL1,
      userAuth.AuthTrustLevel.ATL2,
      userAuth.AuthTrustLevel.ATL3,
    ];
    for (let i = 0; i < levels.length; i++) {
      try {
        userAuth.getAvailableStatus(authType, levels[i]);
        return levels[i];
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        // 12500010 = 未录入；12500005 = 类型不支持。继续尝试其它等级。
        console.info(
          `app_lock getAvailableStatus type=${authType} level=${levels[i]} code=${err?.code}`,
        );
        if (err?.code === 12500010 || err?.code === 12500005) {
          return null;
        }
      }
    }
    return null;
  }

  finishPending(ok: boolean, code: number, token: number): void {
    if (token !== this.startToken) {
      return;
    }
    const reply: MethodResult | null = this.pending;
    this.pending = null;
    this.authInstance = null;
    if (reply === null) {
      return;
    }
    const payload: AppLockAuthReplyPayload = new AppLockAuthReplyPayload();
    payload.ok = ok ? 1 : 0;
    payload.code = code;
    // 回调线程里直接 reply 偶发丢包；下一拍再回传给 Dart。
    setTimeout((): void => {
      reply.success(payload);
    }, 0);
  }
}

const appLockAuthController: AppLockAuthController = new AppLockAuthController();

class AppLockMethodHandler implements MethodCallHandler {
  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method === 'availability') {
      result.success(appLockAuthController.availability());
      return;
    }
    if (call.method === 'authenticate') {
      const method: string = AppLockMethodHandler.readStringArg(call, 'method');
      const reason: string = AppLockMethodHandler.readStringArg(call, 'reason');
      console.info(`app_lock authenticate method=${method}`);
      appLockAuthController.authenticate(method, reason, result);
      return;
    }
    if (call.method === 'cancel') {
      appLockAuthController.cancel();
      result.success(null);
      return;
    }
    result.notImplemented();
  }

  private static readStringArg(call: MethodCall, key: string): string {
    try {
      const value: Object | null = call.argument(key);
      if (value === null || value === undefined) {
        return '';
      }
      return `${value}`;
    } catch (_) {
      return '';
    }
  }
}

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

export default class FortunebootOhosSecurityPlugin
  implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;
  private appLockChannel: MethodChannel | null = null;
  private appLockHandler: AppLockMethodHandler | null = null;

  getUniqueClassName(): string {
    return 'FortunebootOhosSecurityPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
    this.appLockHandler = new AppLockMethodHandler();
    this.appLockChannel = new MethodChannel(
      binding.getBinaryMessenger(),
      APP_LOCK_CHANNEL_NAME,
    );
    this.appLockChannel.setMethodCallHandler(this.appLockHandler);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
    this.appLockChannel?.setMethodCallHandler(null);
    this.appLockChannel = null;
    this.appLockHandler = null;
    appLockAuthController.cancel();
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
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
