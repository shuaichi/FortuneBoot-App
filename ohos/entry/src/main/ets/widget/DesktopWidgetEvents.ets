import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';

/** FormAbility 与 EntryAbility 跨进程通知：日历翻月。 */
const EVENT_CALENDAR_MONTH_CHANGED: string =
  'com.fortuneboot.haoji.DESKTOP_CALENDAR_MONTH_CHANGED';

export class DesktopWidgetEvents {
  private static subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private static handler: ((year: number, month: number) => void) | null = null;

  static publishMonthChanged(year: number, month: number): void {
    const options: commonEventManager.CommonEventPublishData = {
      code: year * 100 + month,
      data: `${year}-${month}`,
    };
    try {
      commonEventManager.publish(EVENT_CALENDAR_MONTH_CHANGED, options, (err: BusinessError) => {
        if (err) {
          console.error(`DesktopWidgetEvents.publish failed: ${JSON.stringify(err)}`);
        }
      });
    } catch (e) {
      console.error(`DesktopWidgetEvents.publish threw: ${String(e)}`);
    }
  }

  static subscribeMonthChanged(handler: (year: number, month: number) => void): void {
    DesktopWidgetEvents.handler = handler;
    if (DesktopWidgetEvents.subscriber !== null) {
      return;
    }
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [EVENT_CALENDAR_MONTH_CHANGED],
    };
    try {
      commonEventManager.createSubscriber(subscribeInfo, DesktopWidgetEvents.onSubscriberCreated);
    } catch (e) {
      console.error(`DesktopWidgetEvents.createSubscriber threw: ${String(e)}`);
    }
  }

  private static onSubscriberCreated = (
    err: BusinessError,
    subscriber: commonEventManager.CommonEventSubscriber,
  ): void => {
    if (err) {
      console.error(`DesktopWidgetEvents.createSubscriber failed: ${JSON.stringify(err)}`);
      return;
    }
    DesktopWidgetEvents.subscriber = subscriber;
    commonEventManager.subscribe(subscriber, (subErr: BusinessError, data: commonEventManager.CommonEventData) => {
      if (subErr) {
        console.error(`DesktopWidgetEvents.subscribe err: ${JSON.stringify(subErr)}`);
        return;
      }
      const raw: string = data.data !== undefined && data.data !== null ? String(data.data) : '';
      const parts: string[] = raw.split('-');
      if (parts.length < 2) {
        return;
      }
      const year: number = Number(parts[0]);
      const month: number = Number(parts[1]);
      if (Number.isNaN(year) || Number.isNaN(month) || year < 1900 || month < 1 || month > 12) {
        return;
      }
      const cb = DesktopWidgetEvents.handler;
      if (cb !== null) {
        cb(year, month);
      }
    });
  };
}
