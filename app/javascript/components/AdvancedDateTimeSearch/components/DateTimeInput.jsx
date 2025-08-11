import 'es6-shim';
import React, { useState, useEffect, useRef, useMemo, forwardRef, useCallback } from 'react';
import { Namespace, TempusDominus } from '@eonasdan/tempus-dominus';

const DateTimeInput = forwardRef((props, datepickerRef) => {
  const {
    inputId,
    inputSuffixId,
    inputName,
    defaultValue,
    minDate,
    maxDate,
    disabled = false,
    localizedDateTimeData = {},
    format = '',
    locale,
  } = props;

  const datepickerContainerRef = useRef();

  // Supported combined formats
  const TYPES = useMemo(
    () => [
      'Y',
      'M',
      'h',
      'YM',
      'MD',
      'hm',
      'YMD',
      'hms',
      'MDh',
      'YMDh',
      'MDhm',
      'YMDhm',
      'MDhms',
      'YMDhms',
    ],
    []
  );

  const EMPTY_PARTS = useMemo(() => ({ Y: '', M: '', D: '', h: '', m: '', s: '' }), []);

  // Compute initial parts from defaultValue and current format
  const initialParts = useMemo(() => {
    const base = defaultValue || EMPTY_PARTS;
    const allowed = new Set(format.split(''));
    const obj = {};
    Object.keys(EMPTY_PARTS).forEach((k) => {
      obj[k] = allowed.has(k) ? base[k] ?? '' : null; // null = key not in current format
    });
    return obj;
  }, [defaultValue, format, EMPTY_PARTS]);

  const [parts, setParts] = useState(initialParts);

  // Keep parts in sync when format or defaultValue changes
  useEffect(() => {
    setParts(initialParts);
  }, [initialParts]);

  // Helper function to convert parts to Date object
  const partsToDate = useCallback((parts) => {
    if (!parts || !Object.values(parts).some(val => val !== '')) {
      return undefined;
    }

    const year = parts.Y || 1970;
    const month = (parts.M || 1) - 1;
    const day = parts.D || 1;
    const hours = parts.h || 0;
    const minutes = parts.m || 0;
    const seconds = parts.s || 0;

    return new Date(year, month, day, hours, minutes, seconds);
  }, []);

  // Init Tempus Dominus datepicker once
  useEffect(() => {
    if (datepickerRef.current || !datepickerContainerRef.current) return;

    const show = {
      Y: format.includes('Y'),
      M: format.includes('M'),
      D: format.includes('D'),
      h: format.includes('h'),
      m: format.includes('m'),
      s: format.includes('s'),
    };

    const dp = new TempusDominus(datepickerContainerRef.current, {
      localization: { locale },
      defaultDate: partsToDate(defaultValue),
      restrictions: {
        minDate: partsToDate(minDate),
        maxDate: partsToDate(maxDate),
      },
      display: {
        icons: {
          type: 'icons',
          time: 'fa fa-clock-o',
          date: 'fa fa-calendar',
          up: 'fa fa-chevron-up',
          down: 'fa fa-chevron-down',
          previous: 'fa fa-arrow-left',
          next: 'fa fa-arrow-right',
          today: 'fa fa-calendar-check',
          clear: 'fa fa-trash',
          close: 'fa fa-times',
        },
        components: {
          calendar: show.D || show.M || show.Y,
          date: show.D,
          month: show.M,
          year: show.Y,
          clock: show.h || show.m || show.s,
          hours: show.h,
          minutes: show.m,
          seconds: show.s,
        },
      },
    });

    datepickerRef.current = dp;
    const unsubscribe = dp.subscribe(Namespace.events.change, onDatepickerChange);

    return () => {
      try {
        unsubscribe?.();
      } catch (_) {}
      try {
        dp?.dispose?.();
      } catch (_) {}
      datepickerRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [format, locale, partsToDate, defaultValue, minDate, maxDate]);

  // Clear when switching to disabled and some field is empty
  const prevDisabledRef = useRef(disabled);
  useEffect(() => {
    if (disabled && !prevDisabledRef.current) {
      const keys = format.split('');
      const filledCount = keys.reduce((acc, k) => acc + (parts?.[k] !== '' ? 1 : 0), 0);
      if (filledCount < keys.length) clearAll();
    }
    prevDisabledRef.current = disabled;
  }, [disabled, format, parts]);

  function onDatepickerChange(event) {
    const date = event?.date;
    if (!date) {
      setParts((p) => ({ ...p, Y: '', M: '', D: '', h: '', m: '', s: '' }));
      return;
    }
    setParts((p) => ({
      ...p,
      Y: date.year ?? '',
      M: date.month != null ? date.month + 1 : '',
      D: date.date ?? '',
      h: date.hours ?? '',
      m: date.minutes ?? '',
      s: date.seconds ?? '',
    }));
  }

  function clearAll() {
    datepickerRef.current?.clear?.();
    setParts((p) => ({ ...p, Y: '', M: '', D: '', h: '', m: '', s: '' }));
  }

  function updatePart(key, val, { min = null, max = null } = {}) {
    let v = parseInt(val, 10);
    if (isNaN(v)) v = '';
    if (v !== '' && ((min != null && v < min) || (max != null && v > max))) return;
    setParts((prev) => ({ ...prev, [key]: v }));
  }

  const onChangeDay = (e) => updatePart('D', e.target.value, { min: 1, max: 31 });
  const onChangeMonth = (e) => updatePart('M', e.target.value, { min: 1, max: 12 });
  const onChangeYear = (e) => updatePart('Y', e.target.value);
  const onChangeHours = (e) => updatePart('h', e.target.value, { min: 0, max: 23 });
  const onChangeMinutes = (e) => updatePart('m', e.target.value, { min: 0, max: 59 });
  const onChangeSeconds = (e) => updatePart('s', e.target.value, { min: 0, max: 59 });

  // Validation helpers
  const allowedFormats = useMemo(() => TYPES.filter((t) => format.includes(t)), [TYPES, format]);

  const currentFormat = useMemo(() => {
    const d = parts || {};
    return format
      .split('')
      .map((k) => (d[k] ? k : ''))
      .join('');
  }, [format, parts]);

  const isValid = useMemo(() => {
    if (currentFormat === '') return true;
    return allowedFormats.includes(currentFormat);
  }, [currentFormat, allowedFormats]);

  const errorStyle = isValid ? {} : { border: '2px solid #f00' };
  const errorMsg = isValid ? '' : 'Invalid value';

  const selectClassName = disabled ? 'form-control disabled' : 'form-control';

  return (
    <div id={`${inputId}_${inputSuffixId}`}>
      {parts && localizedDateTimeData.month_names && (
        <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
          <div>
            {format.includes('D') ? (
              <input
                id={`${inputId}_${inputSuffixId}_day`}
                name={`${inputName}[D]`}
                style={errorStyle}
                type="number"
                min="0"
                max="31"
                className="input-2 form-control"
                value={parts.D ?? ''}
                onChange={onChangeDay}
                readOnly={disabled}
              />
            ) : null}

            {format.includes('M') ? (
              <select
                id={`${inputId}_${inputSuffixId}_month`}
                style={errorStyle}
                name={`${inputName}[M]`}
                className={selectClassName}
                value={parts.M ?? ''}
                onChange={onChangeMonth}
                readOnly={disabled}
              >
                {localizedDateTimeData.month_names.map((month, index) => {
                  let label = month;
                  if (label !== null && typeof label === 'string') {
                    label = label.charAt(0).toUpperCase() + label.slice(1);
                  }
                  // index 0 is the blank value
                  const val = index === 0 ? '' : index;
                  return (
                    <option key={index} value={val}>
                      {label}
                    </option>
                  );
                })}
              </select>
            ) : null}

            {format.includes('Y') ? (
              <input
                id={`${inputId}_${inputSuffixId}_year`}
                name={`${inputName}[Y]`}
                style={errorStyle}
                type="number"
                className={'input-4 form-control'}
                value={parts.Y ?? ''}
                onChange={onChangeYear}
                readOnly={disabled}
              />
            ) : null}

            {format.includes('h') ? (
              <input
                id={`${inputId}_${inputSuffixId}_hour`}
                name={`${inputName}[h]`}
                style={errorStyle}
                min="0"
                max="23"
                type="number"
                className="input-2 form-control"
                value={parts.h ?? ''}
                onChange={onChangeHours}
                readOnly={disabled}
              />
            ) : null}

            {format.includes('m') ? (
              <input
                id={`${inputId}_${inputSuffixId}_minute`}
                name={`${inputName}[m]`}
                style={errorStyle}
                min="0"
                max="59"
                type="number"
                className="input-2 form-control"
                value={parts.m ?? ''}
                onChange={onChangeMinutes}
                readOnly={disabled}
              />
            ) : null}

            {format.includes('s') ? (
              <input
                id={`${inputId}_${inputSuffixId}_second`}
                name={`${inputName}[s]`}
                style={errorStyle}
                min="0"
                max="59"
                type="number"
                className="input-2 form-control"
                value={parts.s ?? ''}
                onChange={onChangeSeconds}
                readOnly={disabled}
              />
            ) : null}

            <div className="calendar-button-container d-inline-flex flex-wrap">
              <div
                id={`datetimepicker-${inputId}`}
                ref={datepickerContainerRef}
                data-td-target-input="nearest"
                data-td-target-toggle="nearest"
              >
                <input data-td-target={`#datetimepicker-${inputId}`} className="d-none" type="text" />
                <a
                  id={`${inputId}_calendar_icon_${inputSuffixId}`}
                  data-td-target={`#datetimepicker-${inputId}`}
                  type="button"
                  data-td-toggle="datetimepicker"
                >
                  <i className="fa fa-calendar"></i>
                </a>
              </div>
              <a onClick={clearAll} type="button">
                <i className="fa fa-times"></i>
              </a>
            </div>
          </div>
        </div>
      )}
      <span className="error helptext">{errorMsg}</span>
    </div>
  );
});

export default DateTimeInput;
