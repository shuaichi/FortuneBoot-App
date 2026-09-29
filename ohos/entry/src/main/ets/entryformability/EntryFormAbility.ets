import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';
import Want from '@ohos.app.ability.Want';
import { DesktopWidgetCalendarSync } from '../widget/DesktopWidgetCalendarSync';
import { DesktopWidgetChannel } from '../widget/DesktopWidgetChannel';
import { DesktopWidgetEvents } from '../widget/DesktopWidgetEvents';
import { DesktopWidgetOrderSync } from '../widget/DesktopWidgetOrderSync';
import { DesktopWidgetStore } from '../widget/DesktopWidgetStore';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const formId = DesktopWidgetStore.formIdFromWant(want);
    const formName = DesktopWidgetStore.formNameFromWant(want);
    console.info(`EntryFormAbility.onAddForm formId=${formId} formName=${formName}`);

    const snapshot = DesktopWidgetStore.createDefaultSnapshot();
    const binding = DesktopWidgetStore.bindingForFormName(snapshot, formName, formId);
    this.refreshFormAsync(formId, formName);
    return binding;
  }

  onUpdateForm(formId: string): void {
    console.info(`EntryFormAbility.onUpdateForm formId=${formId}`);
    this.refreshFormAsync(formId);
  }

  onFormEvent(formId: string, message: string): void {
    console.info(`EntryFormAbility.onFormEvent formId=${formId} message=${message}`);
    const nav = EntryFormAbility.parseNav(message);
    if (nav.kind === 'none') {
      this.refreshFormAsync(formId);
      return;
    }

    if (nav.kind === 'order') {
      const orderDelta = nav.delta;
      DesktopWidgetStore.resolveFormName(this.context, formId)
        .then((formName) => DesktopWidgetStore.addFormId(this.context, formId, formName))
        .then(() => DesktopWidgetOrderSync.cycleOrder(this.context, formId, orderDelta))
        .catch((e: Object) => {
          console.error(`EntryFormAbility.cycleOrder failed: ${String(e)}`);
        });
      return;
    }

    DesktopWidgetStore.resolveFormName(this.context, formId)
      .then((formName) => DesktopWidgetStore.addFormId(this.context, formId, formName)
        .then(() => {
          if (nav.kind === 'year') {
            return DesktopWidgetStore.shiftCalendarYear(this.context, nav.delta)
              .then(async (snapshot) => {
                await formProvider.updateForm(
                  formId,
                  DesktopWidgetStore.toYearBindingData(snapshot),
                );
                DesktopWidgetEvents.publishMonthChanged(snapshot.yearViewYear, 1);
                DesktopWidgetChannel.notifyMonthChanged(snapshot.yearViewYear, 1);
                const synced = await DesktopWidgetCalendarSync.refreshAfterYearChange(
                  this.context,
                  snapshot.yearViewYear,
                );
                if (!synced) {
                  console.warn('EntryFormAbility native year sync skipped/failed');
                }
                return formProvider.setFormNextRefreshTime(formId, 5);
              });
          }
          return DesktopWidgetStore.shiftCalendarMonth(this.context, nav.delta)
            .then(async (snapshot) => {
              await formProvider.updateForm(
                formId,
                DesktopWidgetStore.toDayBindingData(snapshot),
              );
              DesktopWidgetEvents.publishMonthChanged(snapshot.calendarYear, snapshot.calendarMonth);
              DesktopWidgetChannel.notifyMonthChanged(snapshot.calendarYear, snapshot.calendarMonth);
              const synced = await DesktopWidgetCalendarSync.refreshAfterMonthChange(
                this.context,
                snapshot.calendarYear,
                snapshot.calendarMonth,
              );
              if (!synced) {
                console.warn('EntryFormAbility native month sync skipped/failed');
              }
              return formProvider.setFormNextRefreshTime(formId, 5);
            });
        }))
      .catch((e: Object) => {
        console.error(`EntryFormAbility.onFormEvent shift failed: ${String(e)}`);
      });
  }

  onRemoveForm(formId: string): void {
    DesktopWidgetStore.removeFormId(this.context, formId).catch((e: Object) => {
      console.error(`EntryFormAbility.onRemoveForm failed: ${String(e)}`);
    });
  }

  private static parseNav(message: string): NavDelta {
    const result = new NavDelta();
    if (!message || message.length === 0) {
      return result;
    }
    try {
      const parsed: Object = JSON.parse(message) as Object;
      const record = parsed as Record<string, Object>;
      let typeValue: Object | undefined = record['type'];
      if (typeValue === undefined) {
        const params = record['params'];
        if (params !== undefined && typeof params === 'object' && params !== null) {
          typeValue = (params as Record<string, Object>)['type'];
        }
      }
      const type = typeValue !== undefined ? String(typeValue) : '';
      if (type === 'prevMonth') {
        result.kind = 'month';
        result.delta = -1;
        return result;
      }
      if (type === 'nextMonth') {
        result.kind = 'month';
        result.delta = 1;
        return result;
      }
      if (type === 'prevYear') {
        result.kind = 'year';
        result.delta = -1;
        return result;
      }
      if (type === 'nextYear') {
        result.kind = 'year';
        result.delta = 1;
        return result;
      }
      if (type === 'nextOrder' || type === 'prevOrder') {
        result.kind = 'order';
        result.delta = type === 'prevOrder' ? -1 : 1;
        return result;
      }
    } catch (_e) {
      if (message.indexOf('prevMonth') >= 0) {
        result.kind = 'month';
        result.delta = -1;
      } else if (message.indexOf('nextMonth') >= 0) {
        result.kind = 'month';
        result.delta = 1;
      } else if (message.indexOf('prevYear') >= 0) {
        result.kind = 'year';
        result.delta = -1;
      } else if (message.indexOf('nextYear') >= 0) {
        result.kind = 'year';
        result.delta = 1;
      } else if (message.indexOf('prevOrder') >= 0) {
        result.kind = 'order';
        result.delta = -1;
      } else if (message.indexOf('nextOrder') >= 0) {
        result.kind = 'order';
        result.delta = 1;
      }
    }
    return result;
  }

  private refreshFormAsync(formId: string, knownFormName: string = ''): void {
    const namePromise = knownFormName.length > 0
      ? Promise.resolve(knownFormName)
      : DesktopWidgetStore.resolveFormName(this.context, formId);

    namePromise
      .then((formName) => DesktopWidgetStore.addFormId(this.context, formId, formName)
        .then(() => DesktopWidgetStore.readSnapshot(this.context))
        .then(async (snapshot) => {
          await formProvider.updateForm(
            formId,
            DesktopWidgetStore.bindingForFormName(snapshot, formName, formId),
          );
          if (DesktopWidgetStore.isOrderForm(formName)) {
            await DesktopWidgetOrderSync.refreshOrders(this.context);
          } else if (DesktopWidgetStore.isMonthForm(formName)) {
            const year = snapshot.yearViewYear >= 1900
              ? snapshot.yearViewYear
              : new Date().getFullYear();
            await DesktopWidgetCalendarSync.refreshAfterYearChange(this.context, year);
          } else if (DesktopWidgetStore.isDayForm(formName) ||
            (snapshot.calendarYear >= 1900 && snapshot.calendarMonth >= 1)) {
            await DesktopWidgetCalendarSync.refreshAfterMonthChange(
              this.context,
              snapshot.calendarYear,
              snapshot.calendarMonth,
            );
          }
          return formProvider.setFormNextRefreshTime(formId, 5);
        }))
      .catch((e: Object) => {
        console.error(`EntryFormAbility.refreshFormAsync failed: ${String(e)}`);
      });
  }
}

class NavDelta {
  kind: string = 'none';
  delta: number = 0;
}
