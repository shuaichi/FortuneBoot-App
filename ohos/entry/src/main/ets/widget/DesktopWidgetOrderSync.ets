import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import http from '@ohos.net.http';
import formProvider from '@ohos.app.form.formProvider';
import {
  DesktopWidgetSnapshot,
  DesktopWidgetStore,
} from './DesktopWidgetStore';

const FLUTTER_PREFS: string = 'FlutterSharedPreferences';
const KEY_TOKEN: string = 'flutter.userToken';
const KEY_PROTOCOL: string = 'flutter.baseUrlProtocol';
const KEY_DOMAIN: string = 'flutter.baseUrlDomain';
const KEY_PORT: string = 'flutter.baseUrlPort';
const KEY_HIDE: string = 'flutter.fortune.preferences.dashboard.hideAmounts';

class AuthHeaders {
  cookie: string = '';
  authorization: string = '';
}

export class OrderRow {
  id: number = 0;
  title: string = '';
  outCents: number = 0;
  inCents: number = 0;
}

/**
 * 报销单卡片：拉使用中单据，并按 formId 记住当前选中的单。
 */
export class DesktopWidgetOrderSync {
  static async refreshOrders(context: common.Context): Promise<boolean> {
    try {
      const snapshot = await DesktopWidgetStore.readSnapshot(context);
      if (snapshot.bookId <= 0) {
        console.warn('DesktopWidgetOrderSync skip: bookId missing');
        return false;
      }
      const ok = await DesktopWidgetOrderSync.fetchIntoSnapshot(context, snapshot);
      if (!ok) {
        return false;
      }
      await DesktopWidgetStore.writeSnapshot(context, snapshot);
      await DesktopWidgetStore.publishToForms(context);
      return true;
    } catch (e) {
      console.error(`DesktopWidgetOrderSync.refresh failed: ${String(e)}`);
      return false;
    }
  }

  static async cycleOrder(context: common.Context, formId: string, delta: number = 1): Promise<boolean> {
    const snapshot = await DesktopWidgetStore.readSnapshot(context);
    const rows = DesktopWidgetOrderSync.parseOrders(snapshot.ordersPacked);
    if (rows.length === 0) {
      await DesktopWidgetOrderSync.refreshOrders(context);
      return false;
    }
    const currentId = DesktopWidgetStore.getSelectedOrderId(formId, snapshot);
    let index = 0;
    for (let i = 0; i < rows.length; i++) {
      if (rows[i].id === currentId) {
        index = i;
        break;
      }
    }
    const len = rows.length;
    let nextIndex = (index + delta) % len;
    if (nextIndex < 0) {
      nextIndex += len;
    }
    const next = rows[nextIndex];
    DesktopWidgetStore.setSelectedOrderId(snapshot, formId, next.id);
    snapshot.defaultOrderId = next.id;
    snapshot.updatedAt = DesktopWidgetOrderSync.formatClock(new Date());
    snapshot.subtitle = '左右切换报销单';
    await DesktopWidgetStore.writeSnapshot(context, snapshot);
    const binding = DesktopWidgetStore.toOrderBindingData(snapshot, formId);
    await formProvider.updateForm(formId, binding);
    try {
      await formProvider.setFormNextRefreshTime(formId, 5);
    } catch (_e) {
      // optional
    }
    return true;
  }

  private static async fetchIntoSnapshot(
    context: common.Context,
    snapshot: DesktopWidgetSnapshot,
  ): Promise<boolean> {
    const auth = await DesktopWidgetOrderSync.readAuth(context);
    const baseUrl = await DesktopWidgetOrderSync.readBaseUrl(context);
    if (baseUrl.length === 0 || (auth.authorization.length === 0 && auth.cookie.length === 0)) {
      return false;
    }
    const hide = await DesktopWidgetOrderSync.readHideAmounts(context);
    snapshot.hideAmounts = hide;

    // 优先使用中列表；为空则回退分页前 20 条报销单。
    let rows = await DesktopWidgetOrderSync.fetchUsingList(baseUrl, auth, snapshot.bookId);
    if (rows.length === 0) {
      rows = await DesktopWidgetOrderSync.fetchPageList(baseUrl, auth, snapshot.bookId);
    }
    snapshot.ordersPacked = DesktopWidgetOrderSync.packOrders(rows, hide);
    if (rows.length > 0) {
      const stillValid = rows.some((r: OrderRow) => r.id === snapshot.defaultOrderId);
      if (!stillValid) {
        snapshot.defaultOrderId = rows[0].id;
      }
    } else {
      snapshot.defaultOrderId = 0;
    }
    snapshot.updatedAt = DesktopWidgetOrderSync.formatClock(new Date());
    snapshot.subtitle = '左右切换报销单';
    return true;
  }

  private static async fetchUsingList(
    baseUrl: string,
    auth: AuthHeaders,
    bookId: number,
  ): Promise<OrderRow[]> {
    const url = `${baseUrl}/fortune/finance/order/${bookId}/getUsingFinanceOrderList`;
    const body = await DesktopWidgetOrderSync.httpGetJson(url, auth);
    return DesktopWidgetOrderSync.parseApiOrders(body);
  }

  private static async fetchPageList(
    baseUrl: string,
    auth: AuthHeaders,
    bookId: number,
  ): Promise<OrderRow[]> {
    const url =
      `${baseUrl}/fortune/finance/order/getPage?bookId=${bookId}&pageNum=1&pageSize=20&type=1`;
    const body = await DesktopWidgetOrderSync.httpGetJson(url, auth);
    if (body === null) {
      return [];
    }
    const code = DesktopWidgetOrderSync.asNumber(body['code']);
    if (code !== 0) {
      return [];
    }
    const dataObj: Object | undefined = body['data'];
    if (dataObj === undefined || dataObj === null || typeof dataObj !== 'object') {
      return [];
    }
    const data = dataObj as Record<string, Object>;
    const rowsRaw: Object | undefined = data['rows'] ?? data['list'] ?? data['records'];
    return DesktopWidgetOrderSync.mapOrderArray(rowsRaw);
  }

  private static parseApiOrders(body: Record<string, Object> | null): OrderRow[] {
    if (body === null) {
      return [];
    }
    const code = DesktopWidgetOrderSync.asNumber(body['code']);
    if (code !== 0) {
      return [];
    }
    const dataObj: Object | undefined = body['data'];
    // using list 可能直接是 data 数组，也可能包在 data 里。
    if (Array.isArray(dataObj)) {
      return DesktopWidgetOrderSync.mapOrderArray(dataObj);
    }
    if (dataObj !== undefined && dataObj !== null && typeof dataObj === 'object') {
      const data = dataObj as Record<string, Object>;
      const nested: Object | undefined = data['rows'] ?? data['list'];
      if (nested !== undefined) {
        return DesktopWidgetOrderSync.mapOrderArray(nested);
      }
    }
    return [];
  }

  private static mapOrderArray(rowsRaw: Object | undefined): OrderRow[] {
    const result: OrderRow[] = [];
    if (rowsRaw === undefined || rowsRaw === null || !Array.isArray(rowsRaw)) {
      return result;
    }
    const items = rowsRaw as Object[];
    for (let i = 0; i < items.length && result.length < 30; i++) {
      const item = items[i] as Record<string, Object>;
      const id = DesktopWidgetOrderSync.asNumber(item['orderId']);
      if (id <= 0) {
        continue;
      }
      const row = new OrderRow();
      row.id = id;
      const titleRaw = item['title'] !== undefined ? String(item['title']) : '';
      row.title = titleRaw.length > 0 ? titleRaw : '未命名报销单';
      const out = DesktopWidgetOrderSync.asNumber(item['outAmount']);
      const inn = DesktopWidgetOrderSync.asNumber(item['inAmount']);
      row.outCents = Math.round(out * 100);
      row.inCents = Math.round(inn * 100);
      result.push(row);
    }
    return result;
  }

  static packOrders(rows: OrderRow[], hide: boolean): string {
    const parts: string[] = [];
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const title = DesktopWidgetOrderSync.sanitize(row.title);
      if (hide) {
        parts.push(`${row.id}|${title}|*|*`);
      } else {
        parts.push(`${row.id}|${title}|${row.outCents}|${row.inCents}`);
      }
    }
    return parts.join(';');
  }

  static parseOrders(packed: string): OrderRow[] {
    const result: OrderRow[] = [];
    if (!packed || packed.length === 0) {
      return result;
    }
    const parts = packed.split(';');
    for (let i = 0; i < parts.length; i++) {
      const item = parts[i];
      if (item.length === 0) {
        continue;
      }
      const fields = item.split('|');
      if (fields.length < 4) {
        continue;
      }
      const row = new OrderRow();
      row.id = Number(fields[0]);
      if (Number.isNaN(row.id) || row.id <= 0) {
        continue;
      }
      row.title = fields[1];
      if (fields[2] === '*') {
        row.outCents = -1;
      } else {
        row.outCents = Number(fields[2]);
      }
      if (fields[3] === '*') {
        row.inCents = -1;
      } else {
        row.inCents = Number(fields[3]);
      }
      result.push(row);
    }
    return result;
  }

  static formatOrderAmount(cents: number, hide: boolean): string {
    if (hide || cents < 0) {
      return '****';
    }
    return DesktopWidgetOrderSync.formatMoney(cents / 100);
  }

  private static sanitize(title: string): string {
    let t = title.replace(/\|/g, '/').replace(/;/g, ',');
    if (t.length > 24) {
      t = t.substring(0, 24);
    }
    return t;
  }

  private static async httpGetJson(url: string, auth: AuthHeaders): Promise<Record<string, Object> | null> {
    const client = http.createHttp();
    try {
      const header: Record<string, string> = {
        'Content-Type': 'application/json',
      };
      if (auth.authorization.length > 0) {
        header['Authorization'] = auth.authorization;
      }
      if (auth.cookie.length > 0) {
        header['Cookie'] = auth.cookie;
      }
      const response = await client.request(url, {
        method: http.RequestMethod.GET,
        header: header,
        connectTimeout: 10000,
        readTimeout: 15000,
        expectDataType: http.HttpDataType.STRING,
      });
      if (response.responseCode < 200 || response.responseCode >= 300) {
        return null;
      }
      const raw = typeof response.result === 'string' ? response.result : String(response.result);
      const parsed: Object = JSON.parse(raw) as Object;
      if (typeof parsed !== 'object' || parsed === null) {
        return null;
      }
      return parsed as Record<string, Object>;
    } catch (e) {
      console.error(`DesktopWidgetOrderSync http failed: ${String(e)}`);
      return null;
    } finally {
      client.destroy();
    }
  }

  private static async flutterPrefs(context: common.Context): Promise<dataPreferences.Preferences> {
    let resolved: common.Context = context;
    try {
      const appContext = context.getApplicationContext();
      if (appContext) {
        resolved = appContext;
      }
    } catch (_e) {
      // ignore
    }
    try {
      await dataPreferences.removePreferencesFromCache(resolved, FLUTTER_PREFS);
    } catch (_e) {
      // ignore
    }
    return await dataPreferences.getPreferences(resolved, FLUTTER_PREFS);
  }

  private static async readAuth(context: common.Context): Promise<AuthHeaders> {
    const headers = new AuthHeaders();
    const prefs = await DesktopWidgetOrderSync.flutterPrefs(context);
    const raw = await prefs.get(KEY_TOKEN, '');
    if (typeof raw !== 'string' || raw.length === 0) {
      return headers;
    }
    try {
      const parsed: Object = JSON.parse(raw) as Object;
      const map = parsed as Record<string, Object>;
      if (map['Cookie'] !== undefined) {
        headers.cookie = String(map['Cookie']);
      }
      if (map['Authorization'] !== undefined) {
        headers.authorization = String(map['Authorization']);
      }
    } catch (_e) {
      // ignore
    }
    return headers;
  }

  private static async readBaseUrl(context: common.Context): Promise<string> {
    const prefs = await DesktopWidgetOrderSync.flutterPrefs(context);
    const protocolRaw = await prefs.get(KEY_PROTOCOL, '');
    const domainRaw = await prefs.get(KEY_DOMAIN, '');
    const portRaw = await prefs.get(KEY_PORT, '');
    const protocol = typeof protocolRaw === 'string' ? protocolRaw.trim() : '';
    const domain = typeof domainRaw === 'string' ? domainRaw.trim() : '';
    const port = typeof portRaw === 'string' ? portRaw.trim() : '';
    if (protocol.length === 0 || domain.length === 0) {
      return '';
    }
    const host = port.length > 0 ? `${domain}:${port}` : domain;
    return `${protocol}://${host}/prod-api`;
  }

  private static async readHideAmounts(context: common.Context): Promise<boolean> {
    const prefs = await DesktopWidgetOrderSync.flutterPrefs(context);
    const raw = await prefs.get(KEY_HIDE, false);
    if (typeof raw === 'boolean') {
      return raw;
    }
    return raw === 'true' || raw === 1;
  }

  private static formatMoney(value: number): string {
    const fixed = value.toFixed(2);
    const parts = fixed.split('.');
    let intPart = parts[0];
    const decPart = parts.length > 1 ? parts[1] : '00';
    const negative = intPart.indexOf('-') === 0;
    if (negative) {
      intPart = intPart.substring(1);
    }
    let grouped = '';
    let count = 0;
    for (let i = intPart.length - 1; i >= 0; i--) {
      grouped = intPart.charAt(i) + grouped;
      count++;
      if (count === 3 && i > 0) {
        grouped = ',' + grouped;
        count = 0;
      }
    }
    return `${negative ? '-' : ''}${grouped}.${decPart}`;
  }

  private static formatClock(now: Date): string {
    const h = now.getHours();
    const m = now.getMinutes();
    const hh = h < 10 ? `0${h}` : `${h}`;
    const mm = m < 10 ? `0${m}` : `${m}`;
    return `${hh}:${mm}`;
  }

  private static asNumber(value: Object | undefined): number {
    if (value === undefined || value === null) {
      return 0;
    }
    if (typeof value === 'number') {
      return value;
    }
    const n = Number(String(value));
    return Number.isNaN(n) ? 0 : n;
  }
}
