import common from '@ohos.app.ability.common';
import fileIo from '@ohos.file.fs';
import fileUri from '@ohos.file.fileuri';
import picker from '@ohos.file.picker';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
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

  getUniqueClassName(): string {
    return 'FortunebootOhosSecurityPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.channel?.setMethodCallHandler(null);
    this.channel = null;
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
