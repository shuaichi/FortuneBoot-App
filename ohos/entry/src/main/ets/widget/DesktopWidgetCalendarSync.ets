import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import http from '@ohos.net.http';
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

class DayBucket {
  income: number = 0;
  expense: number = 0;
}

/**
 * Form 扩展内拉收支日历：不依赖 Flutter 是否在前台/后台被挂起。
 */
export class DesktopWidgetCalendarSync {
  static async refreshAfterMonthChange(
    context: common.Context,
    year: number,
    month: number,
  ): Promise<boolean> {
    try {
      const snapshot = await DesktopWidgetStore.readSnapshot(context);
      if (snapshot.bookId <= 0) {
        console.warn('DesktopWidgetCalendarSync skip: bookId missing');
        return false;
      }
      const filled = await DesktopWidgetCalendarSync.fetchDayIntoSnapshot(
        context,
        snapshot,
        year,
        month,
      );
      if (!filled) {
        return false;
      }
      await DesktopWidgetStore.writeSnapshot(context, snapshot);
      await DesktopWidgetStore.publishToForms(context);
      return true;
    } catch (e) {
      console.error(`DesktopWidgetCalendarSync.refresh failed: ${String(e)}`);
      return false;
    }
  }

  static async refreshAfterYearChange(
    context: common.Context,
    year: number,
  ): Promise<boolean> {
    try {
      const snapshot = await DesktopWidgetStore.readSnapshot(context);
      if (snapshot.bookId <= 0) {
        console.warn('DesktopWidgetCalendarSync year skip: bookId missing');
        return false;
      }
      const filled = await DesktopWidgetCalendarSync.fetchYearIntoSnapshot(
        context,
        snapshot,
        year,
      );
      if (!filled) {
        return false;
      }
      await DesktopWidgetStore.writeSnapshot(context, snapshot);
      await DesktopWidgetStore.publishToForms(context);
      return true;
    } catch (e) {
      console.error(`DesktopWidgetCalendarSync.year refresh failed: ${String(e)}`);
      return false;
    }
  }

  private static async fetchDayIntoSnapshot(
    context: common.Context,
    snapshot: DesktopWidgetSnapshot,
    year: number,
    month: number,
  ): Promise<boolean> {
    const auth = await DesktopWidgetCalendarSync.readAuth(context);
    const baseUrl = await DesktopWidgetCalendarSync.readBaseUrl(context);
    if (baseUrl.length === 0) {
      console.warn('DesktopWidgetCalendarSync skip: baseUrl missing');
      return false;
    }
    if (auth.authorization.length === 0 && auth.cookie.length === 0) {
      console.warn('DesktopWidgetCalendarSync skip: auth missing');
      return false;
    }

    const hide = await DesktopWidgetCalendarSync.readHideAmounts(context);
    snapshot.hideAmounts = hide;

    const url =
      `${baseUrl}/fortune/include/getIncomeExpenseCalendar` +
      `?bookId=${snapshot.bookId}&granularity=1&year=${year}&month=${month}`;

    const body = await DesktopWidgetCalendarSync.httpGetJson(url, auth);
    if (body === null) {
      return false;
    }
    const codeRaw: Object | undefined = body['code'];
    const code = typeof codeRaw === 'number' ? codeRaw : Number(codeRaw);
    if (code !== 0) {
      console.warn(`DesktopWidgetCalendarSync api code=${String(codeRaw)}`);
      return false;
    }
    const dataObj: Object | undefined = body['data'];
    if (dataObj === undefined || dataObj === null || typeof dataObj !== 'object') {
      return false;
    }
    const data = dataObj as Record<string, Object>;
    const itemsRaw: Object | undefined = data['items'];
    const byDay = DesktopWidgetCalendarSync.mergeDayItems(itemsRaw, year, month);

    let monthIncome = 0;
    let monthExpense = 0;
    const dayParts: string[] = [];
    const days: number[] = [];
    const keys = Object.keys(byDay);
    for (let i = 0; i < keys.length; i++) {
      days.push(Number(keys[i]));
    }
    days.sort((a: number, b: number) => a - b);
    for (let i = 0; i < days.length; i++) {
      const day = days[i];
      const bucket = byDay[`${day}`];
      if (bucket === undefined) {
        continue;
      }
      monthIncome += bucket.income;
      monthExpense += bucket.expense;
      if (bucket.income === 0 && bucket.expense === 0) {
        continue;
      }
      dayParts.push(
        `${day}:${DesktopWidgetCalendarSync.packCents(bucket.income, hide)}:` +
          `${DesktopWidgetCalendarSync.packCents(bucket.expense, hide)}`,
      );
    }

    const now = new Date();
    const isCurrent = now.getFullYear() === year && (now.getMonth() + 1) === month;
    const todayMark = isCurrent ? now.getDate() : 0;
    const mm = month < 10 ? `0${month}` : `${month}`;
    snapshot.calendarYear = year;
    snapshot.calendarMonth = month;
    snapshot.monthTitle = DesktopWidgetStore.monthTitle(year, month);
    snapshot.weekdays = '一二三四五六日';
    snapshot.cellsJson = `${year}-${mm}|${todayMark}|${dayParts.join(';')}`;
    snapshot.monthIncomeText = hide ? '****' : DesktopWidgetCalendarSync.formatMoney(monthIncome);
    snapshot.monthExpenseText = hide ? '****' : DesktopWidgetCalendarSync.formatMoney(monthExpense);
    await DesktopWidgetCalendarSync.refreshNetAssets(context, snapshot, auth, baseUrl, hide);
    snapshot.updatedAt = DesktopWidgetCalendarSync.formatClock(now);
    snapshot.subtitle = '翻月自动同步';
    return true;
  }

  private static async fetchYearIntoSnapshot(
    context: common.Context,
    snapshot: DesktopWidgetSnapshot,
    year: number,
  ): Promise<boolean> {
    const auth = await DesktopWidgetCalendarSync.readAuth(context);
    const baseUrl = await DesktopWidgetCalendarSync.readBaseUrl(context);
    if (baseUrl.length === 0 || (auth.authorization.length === 0 && auth.cookie.length === 0)) {
      return false;
    }
    const hide = await DesktopWidgetCalendarSync.readHideAmounts(context);
    snapshot.hideAmounts = hide;

    const url =
      `${baseUrl}/fortune/include/getIncomeExpenseCalendar` +
      `?bookId=${snapshot.bookId}&granularity=2&year=${year}`;
    const body = await DesktopWidgetCalendarSync.httpGetJson(url, auth);
    if (body === null) {
      return false;
    }
    const codeRaw: Object | undefined = body['code'];
    const code = typeof codeRaw === 'number' ? codeRaw : Number(codeRaw);
    if (code !== 0) {
      return false;
    }
    const dataObj: Object | undefined = body['data'];
    if (dataObj === undefined || dataObj === null || typeof dataObj !== 'object') {
      return false;
    }
    const data = dataObj as Record<string, Object>;
    const byMonth = DesktopWidgetCalendarSync.mergeMonthItems(data['items'], year);

    let yearIncome = 0;
    let yearExpense = 0;
    const monthParts: string[] = [];
    for (let month = 1; month <= 12; month++) {
      const bucket = byMonth[`${month}`];
      if (bucket === undefined) {
        continue;
      }
      yearIncome += bucket.income;
      yearExpense += bucket.expense;
      if (bucket.income === 0 && bucket.expense === 0) {
        continue;
      }
      monthParts.push(
        `${month}:${DesktopWidgetCalendarSync.packCents(bucket.income, hide)}:` +
          `${DesktopWidgetCalendarSync.packCents(bucket.expense, hide)}`,
      );
    }

    const now = new Date();
    const currentMonth = (now.getFullYear() === year) ? (now.getMonth() + 1) : 0;
    snapshot.yearViewYear = year;
    snapshot.yearTitle = DesktopWidgetStore.yearTitleOf(year);
    snapshot.yearCellsJson = `${year}|${currentMonth}|${monthParts.join(';')}`;
    snapshot.yearIncomeText = hide ? '****' : DesktopWidgetCalendarSync.formatMoney(yearIncome);
    snapshot.yearExpenseText = hide ? '****' : DesktopWidgetCalendarSync.formatMoney(yearExpense);
    await DesktopWidgetCalendarSync.refreshNetAssets(context, snapshot, auth, baseUrl, hide);
    snapshot.updatedAt = DesktopWidgetCalendarSync.formatClock(now);
    snapshot.subtitle = '翻年自动同步';
    return true;
  }

  private static async refreshNetAssets(
    context: common.Context,
    snapshot: DesktopWidgetSnapshot,
    auth: AuthHeaders,
    baseUrl: string,
    hide: boolean,
  ): Promise<void> {
    if (snapshot.groupId <= 0) {
      return;
    }
    const url = `${baseUrl}/fortune/include/${snapshot.groupId}/getFortuneAssetsLiabilities`;
    const body = await DesktopWidgetCalendarSync.httpGetJson(url, auth);
    if (body === null) {
      return;
    }
    const codeRaw: Object | undefined = body['code'];
    const code = typeof codeRaw === 'number' ? codeRaw : Number(codeRaw);
    if (code !== 0) {
      return;
    }
    const dataObj: Object | undefined = body['data'];
    if (dataObj === undefined || dataObj === null || typeof dataObj !== 'object') {
      return;
    }
    const data = dataObj as Record<string, Object>;
    const netAssets = DesktopWidgetCalendarSync.asNumber(data['netAssets']);
    const totalAssets = DesktopWidgetCalendarSync.asNumber(data['totalAssets']);
    const totalLiabilities = DesktopWidgetCalendarSync.asNumber(data['totalLiabilities']);
    const value = data['netAssets'] !== undefined ? netAssets : (totalAssets - totalLiabilities);
    snapshot.netAssetsText = hide ? '****' : DesktopWidgetCalendarSync.formatMoney(value);
  }

  private static mergeDayItems(
    itemsRaw: Object | undefined,
    year: number,
    month: number,
  ): Record<string, DayBucket> {
    const byDay: Record<string, DayBucket> = {};
    if (itemsRaw === undefined || itemsRaw === null || !Array.isArray(itemsRaw)) {
      return byDay;
    }
    const items = itemsRaw as Object[];
    for (let i = 0; i < items.length; i++) {
      const item = items[i] as Record<string, Object>;
      const period = item['period'] !== undefined ? String(item['period']) : '';
      const day = DesktopWidgetCalendarSync.dayFromPeriod(period, year, month);
      if (day === null) {
        continue;
      }
      const income = DesktopWidgetCalendarSync.asNumber(item['income']);
      const expense = DesktopWidgetCalendarSync.asNumber(item['expense']);
      const key = `${day}`;
      let bucket = byDay[key];
      if (bucket === undefined) {
        bucket = new DayBucket();
        byDay[key] = bucket;
      }
      bucket.income += income;
      bucket.expense += expense;
    }
    return byDay;
  }

  private static mergeMonthItems(
    itemsRaw: Object | undefined,
    year: number,
  ): Record<string, DayBucket> {
    const byMonth: Record<string, DayBucket> = {};
    if (itemsRaw === undefined || itemsRaw === null || !Array.isArray(itemsRaw)) {
      return byMonth;
    }
    const items = itemsRaw as Object[];
    for (let i = 0; i < items.length; i++) {
      const item = items[i] as Record<string, Object>;
      const period = item['period'] !== undefined ? String(item['period']) : '';
      const month = DesktopWidgetCalendarSync.monthFromPeriod(period, year);
      if (month === null) {
        continue;
      }
      const income = DesktopWidgetCalendarSync.asNumber(item['income']);
      const expense = DesktopWidgetCalendarSync.asNumber(item['expense']);
      const key = `${month}`;
      let bucket = byMonth[key];
      if (bucket === undefined) {
        bucket = new DayBucket();
        byMonth[key] = bucket;
      }
      bucket.income += income;
      bucket.expense += expense;
    }
    return byMonth;
  }

  private static monthFromPeriod(period: string, year: number): number | null {
    const normalized = period.trim().replace(/\//g, '-');
    const parts = normalized.split('-');
    if (parts.length !== 2) {
      return null;
    }
    const y = Number(parts[0]);
    const m = Number(parts[1]);
    if (y !== year || Number.isNaN(m) || m < 1 || m > 12) {
      return null;
    }
    return m;
  }

  private static dayFromPeriod(period: string, year: number, month: number): number | null {
    const normalized = period.trim().replace(/\//g, '-');
    const parts = normalized.split('-');
    if (parts.length !== 3) {
      return null;
    }
    const y = Number(parts[0]);
    const m = Number(parts[1]);
    const d = Number(parts[2]);
    if (y !== year || m !== month || Number.isNaN(d)) {
      return null;
    }
    const maxDay = new Date(year, month, 0).getDate();
    if (d < 1 || d > maxDay) {
      return null;
    }
    return d;
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
        console.warn(`DesktopWidgetCalendarSync http status=${response.responseCode}`);
        return null;
      }
      const raw = typeof response.result === 'string' ? response.result : String(response.result);
      const parsed: Object = JSON.parse(raw) as Object;
      if (typeof parsed !== 'object' || parsed === null) {
        return null;
      }
      return parsed as Record<string, Object>;
    } catch (e) {
      console.error(`DesktopWidgetCalendarSync http failed: ${String(e)}`);
      return null;
    } finally {
      client.destroy();
    }
  }

  private static async flutterPrefs(context: common.Context): Promise<dataPreferences.Preferences> {
    const resolved = DesktopWidgetCalendarSync.resolveContext(context);
    try {
      await dataPreferences.removePreferencesFromCache(resolved, FLUTTER_PREFS);
    } catch (_e) {
      // ignore
    }
    return await dataPreferences.getPreferences(resolved, FLUTTER_PREFS);
  }

  private static resolveContext(context: common.Context): common.Context {
    try {
      const appContext = context.getApplicationContext();
      if (appContext) {
        return appContext;
      }
    } catch (_e) {
      // ignore
    }
    return context;
  }

  private static async readAuth(context: common.Context): Promise<AuthHeaders> {
    const headers = new AuthHeaders();
    const prefs = await DesktopWidgetCalendarSync.flutterPrefs(context);
    const raw = await prefs.get(KEY_TOKEN, '');
    if (typeof raw !== 'string' || raw.length === 0) {
      return headers;
    }
    try {
      const parsed: Object = JSON.parse(raw) as Object;
      const map = parsed as Record<string, Object>;
      const cookie = map['Cookie'];
      const authorization = map['Authorization'];
      if (cookie !== undefined && cookie !== null) {
        headers.cookie = String(cookie);
      }
      if (authorization !== undefined && authorization !== null) {
        headers.authorization = String(authorization);
      }
    } catch (e) {
      console.error(`DesktopWidgetCalendarSync parse token failed: ${String(e)}`);
    }
    return headers;
  }

  private static async readBaseUrl(context: common.Context): Promise<string> {
    const prefs = await DesktopWidgetCalendarSync.flutterPrefs(context);
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
    const prefs = await DesktopWidgetCalendarSync.flutterPrefs(context);
    const raw = await prefs.get(KEY_HIDE, false);
    if (typeof raw === 'boolean') {
      return raw;
    }
    if (raw === 'true' || raw === 1) {
      return true;
    }
    return false;
  }

  private static packCents(value: number, hide: boolean): string {
    if (hide) {
      return '*';
    }
    if (value === 0) {
      return '';
    }
    return `${Math.round(value * 100)}`;
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
