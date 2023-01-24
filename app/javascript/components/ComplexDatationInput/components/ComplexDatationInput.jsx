import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect} from 'react';
import Translations from '../../Translations/components/Translations';
import AsyncPaginate from 'react-select-async-paginate';
import axios from "axios";
import DateTimeInput from '../../DateTimeInput/components/DateTimeInput';

const ComplexDatationInput = (props) => {
    const defaultValues = {Y: "", M: "", D: "", h: "", m: "", s: ""};
    const types = ["Y", "M", "h", "YM", "MD", "hm", "YMD", "hms", "MDh", "YMDh", "MDhm", "YMDhm", "MDhms", "YMDhms"];

    const {
        input,
        locales,
        choiceSets: choiceSetsProps,
        selectedFormat: selectedFormatProps,
        fieldUuid
    } = props

    const [choiceSets, setChoiceSets] = useState(choiceSetsProps)
    const [choiceData, _setChoiceData] = useState(choiceSetsProps.map(c => c.selectedChoicesValue.map(s => s.value.toString())))

    const [state, setState] = useState(false)
    const [fromState, setFromState] = useState(false)
    const [toState, setToState] = useState(false)
    const [date, setDate] = useState(getData())
    const [granularity, setGranularity] = useState(getFieldOptions().format)
    const [isRequired, setIsRequired] = useState(false)

    const [allowedFormats, setAllowedFormats] = useState(getFieldOptions().allowed_formats.filter(f => f !== ''))
    const [selectedFormat, setSelectedFormat] = useState(selectedFormatProps[0])
    const [allowBC, setAllowBC] = useState(getFieldOptions().allow_date_time_bc === '1')

    const setChoiceData = (index, value) => {
        let data = choiceData
        data[index] = value
        _setChoiceData(data)
        setData({...getData(), 'selected_choices': {value: data.flat()}})
    }

    useEffect(() => {
        setSelectedFormat(selectedFormatProps[0])
    }, [selectedFormatProps])

    const setSelectedFormatAndUpdateData = (format) => {
        setSelectedFormat(format);
        if (format === 'date_time') {
            setData({...getData(), 'selected_format': format, selected_choices: {}, from: fromState, to: toState})
        } else {
            setData({
                ...getData(),
                'selected_format': format,
                selected_choices: {value: choiceData.flat()},
                from: {},
                to: {}
            })
        }
    }

    const renderAllowedFormatsSelector = () => {
        if (allowedFormats.length === 2) {
            return (
                allowedFormats.map((allowedFormat, idx) => (
                    <div className="form-check" key={`allowedFormat-${idx}`}>
                        <input className="form-check-input" type="radio" name="allowedFormat"
                               id={`allowedFormat-${idx}`}
                               checked={selectedFormat === allowedFormat}
                               onChange={() => setSelectedFormatAndUpdateData(allowedFormat)}/>
                        <label className=" form-check-label"
                               htmlFor={`allowedFormat-${idx}`}>{Translations.messages[`catalog_admin.fields.complex_datation_option_inputs.${allowedFormat}`]}</label>
                    </div>
                ))
            )
        } else {
            return ''
        }
    }

    useEffect(() => {
        if (document.querySelector(input) !== null) {
            setIsRequired(document.querySelector(input).getAttribute('data-field-required') == 'true')
        }

        if (jQuery.isEmptyObject(getData()['from'])) return initData(defaultValues, getFieldOptions().format);
    }, [])

    const dateFromGranularityAndDate = (input) => {
        let s = {}
        for (let i in granularity) {
            let k = granularity[i];
            s[k] = date[input][k] || (defaultValues)[k];
        }
        s['BC'] = date[input]['BC'] || false
        return s
    }

    useEffect(() => {
        if (date['selected_format']) {
            setSelectedFormat(date['selected_format'])
        } else {
            setSelectedFormat(selectedFormatProps[0])
            setData({...getData(), 'selected_format': selectedFormatProps[0]})
        }

        let from = dateFromGranularityAndDate('from')
        setFromState(from);
        let to = dateFromGranularityAndDate('to')
        setToState(to);
    }, [granularity])

    let dateValid = isCurrentFormatValid();
    let errorStl = dateValid ? {} : {border: "2px solid #f00"};
    let errorMsg = dateValid ? "" : "Invalid value";
    let fmt = getFieldOptions().format;

    function _handleChangeBC(input) {
        return function (e) {
            updateDateData(input, {BC: e.target.checked});
        }
    }


    function _handleChangeDay(input) {
        return function (e) {
            let v = parseInt(e.target.value);
            if (v < 1 || v > 31) return;
            if (isNaN(v)) v = "";
            updateDateData(input, {D: v});
        }
    }

    function _handleChangeMonth(input) {
        return function (e) {
            let v = parseInt(e.target.value);
            if (v < 1 || v > 12) return;
            if (isNaN(v)) v = "";
            updateDateData(input, {M: v});
        }
    }

    function _handleChangeYear(input) {
        return function (e) {
            let v = parseInt(e.target.value);
            if (isNaN(v)) v = "";
            updateDateData(input, {Y: v});
        }
    }

    function _handleChangeHours(input) {
        return function (e) {
            let v = parseInt(e.target.value);
            if (v < 0 || v > 23) return;
            if (isNaN(v)) v = "";
            updateDateData(input, {h: v});
        }
    }

    function _handleChangeMinutes(input) {
        return function (e) {
            let v = parseInt(e.target.value);
            if (v < 0 || v > 59) return;
            if (isNaN(v)) v = "";
            updateDateData(input, {m: v});
        }
    }

    function _handleChangeSeconds(input) {
        return function (e) {
            let v = parseInt(e.target.value);
            if (v < 0 || v > 59) return;
            if (isNaN(v)) v = "";
            updateDateData(input, {s: v});
        }
    }

    function initData(data, format) {
        let dt = {};
        for (let i in data) {
            dt[i] = format.includes(i) ? data[i] || "" : null;
        }
        updateDateData('from', {...dt, BC: false});
        updateDateData('to', {...dt, BC: false});
    }

    function updateDateData(input, h) {
        let newState
        if (input === 'from') {
            setFromState(fromState ? {...fromState, ...h} : h);
            newState = {from: fromState ? {...fromState, ...h} : h}
        } else if (input === 'to') {
            setToState(toState ? {...toState, ...h} : h);
            newState = {to: toState ? {...toState, ...h} : h}
        }

        setState(state ? {...state, ...newState} : newState);
        const d = getData();

        if (input === 'from') {
            for (let k in h) d['from'][k] = h[k];
        } else {
            for (let k in h) d['to'][k] = h[k];
        }

        setData(d);
    }

    function getData() {
        const value = getInput().val();
        if (!value) return {'from': {}, 'to': {}};
        let v = JSON.parse(value);
        return v.raw_value ? rawValueToDateTime(v.raw_value) : v;
    }

    function rawValueToDateTime(v) {
        const dt = new Date(v * 1000);
        return {
            Y: dt.getFullYear(),
            M: dt.getMonth() + 1,
            D: dt.getDate(),
            h: dt.getHours(),
            m: dt.getMinutes(),
            s: dt.getSeconds()
        };
    }

    function setData(d) {
        getInput().val(JSON.stringify(d));
    }

    function getInput() {
        return $(input);
    }

    function getAllowedFormats() {
        const granularity = getFieldOptions().format;
        return types.filter(obj => {
            if (granularity.includes(obj) || granularity == obj) return obj;
        });
    }

    function getCurrentFormat() {
        let d = getData();
        let f = getFieldOptions().format;
        return f.split('').map(function (k) {
            return d['from'][k] ? k : d['to'][k] ? k : '';
        }).join('')
    }

    function isCurrentFormatValid() {
        let current = getCurrentFormat();
        if (current === '' && !isRequired) return true;   // allow empty value if field is not required
        let allowed = getAllowedFormats();
        return allowed.indexOf(current) > -1;
    }

    function getFieldOptions() {
        return getInput().data("field-options") || {format: 'YMD'};
    }


    const renderDateTimeInput = (input) => {
        return (
            <div className="dateTimeInput rails-bootstrap-forms-datetime-select">
                {allowBC ? (
                    <div className="form-check"
                         style={{display: 'inline-block', marginRight: '3rem', paddingLeft: '0'}}>
                        <label className="form-check-label"
                               htmlFor={`bcCheck-${input}`}>{Translations.messages['catalog_admin.fields.complex_datation_option_inputs.BC']}</label>
                        <input type="checkbox" value={true} className="form-check-input" id={`bcCheck-${input}`}
                               checked={input === 'from' ? fromState.BC : toState.BC}
                               onChange={_handleChangeBC(input)}/>
                    </div>
                ) : null}
                {fmt.includes('D') ? (
                    <input style={errorStl} type="number" min="0" max="31" className="input-2 form-control"
                           value={input === 'from' ? fromState.D : toState.D}
                           onChange={_handleChangeDay(input)}/>
                ) : null
                }
                {fmt.includes('M') ? (
                    <select style={errorStl} className="form-control" value={input === 'from' ? fromState.M : toState.M}
                            onChange={_handleChangeMonth(input)}>
                        <option value=""></option>
                        <option value="1">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.january']}
                        </option>
                        <option value="2">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.february']}
                        </option>
                        <option value="3">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.march']}
                        </option>
                        <option value="4">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.april']}
                        </option>
                        <option value="5">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.may']}
                        </option>
                        <option value="6">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.june']}
                        </option>
                        <option value="7">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.july']}
                        </option>
                        <option value="8">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.august']}
                        </option>
                        <option value="9">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.september']}
                        </option>
                        <option value="10">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.october']}
                        </option>
                        <option value="11">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.november']}
                        </option>
                        <option value="12">
                            {Translations.messages['catalog_admin.fields.date_time_option_inputs.months.december']}
                        </option>
                    </select>) : null
                }
                {fmt.includes('Y') ? (
                    <input style={errorStl} className="input-4 margin-right form-control"
                           type="number" min="0"
                           value={input === 'from' ? fromState.Y : toState.Y}
                           onChange={_handleChangeYear(input)}/>
                ) : null
                }
                {fmt.includes('h') ? (
                    <input style={errorStl} min="0" max="23" type="number" className="input-2 form-control"
                           value={input === 'from' ? fromState.h : toState.h}
                           onChange={_handleChangeHours(input)}/>
                ) : null
                }
                {fmt.includes('m') ? (
                    <input style={errorStl} min="0" max="59" type="number" className="input-2 form-control"
                           value={input === 'from' ? fromState.m : toState.m}
                           onChange={_handleChangeMinutes(input)}/>
                ) : null
                }
                {fmt.includes('s') ? (
                    <input style={errorStl} min="0" max="59" type="number" className="input-2 form-control"
                           value={input === 'from' ? fromState.s : toState.s}
                           onChange={_handleChangeSeconds(input)}/>
                ) : null
                }
                <span className="text-muted">
          {Translations.messages[`catalog_admin.fields.complex_datation_option_inputs.${input === 'from' ? 'from_date' : 'to_date'}`]}
        </span>
            </div>
        )
    }

    if (!fromState || !toState) return ""
    return (
        <div>
            <div>{renderAllowedFormatsSelector()}</div>
            {selectedFormat == 'date_time' && (
                <div>
                    <div>{renderDateTimeInput('from')}</div>
                    <div>{renderDateTimeInput('to')}</div>
                    <span className="error helptext">{errorMsg}</span>
                </div>
            )}
            {selectedFormat == 'datation_choice' && (
                <RenderChoiceSetList
                    choiceSets={choiceSets}
                    locales={locales}
                    getData={getData}
                    setData={setData}
                    setChoiceData={setChoiceData}
                    fieldUuid={fieldUuid}
                />
            )}
        </div>
    )
}

ComplexDatationInput.propTypes = {
    input: PropTypes.string.isRequired,
}

export default ComplexDatationInput;


const RenderChoiceSetList = (props) => {
    const {
        locales,
        choiceSets,
        getData,
        setData,
        setChoiceData,
        fieldUuid
    } = props


    function renderChoiceSet(choiceSet, index, list) {
        if (Object.keys(choiceSet).length > 0) {
            return (<div key={choiceSet.fetchUrl} className="mt-2">
                <RenderChoiceSetInput
                    name={choiceSet.name}
                    locales={locales}
                    fetchUrl={choiceSet.fetchUrl}
                    selectedChoicesValue={choiceSet.selectedChoicesValue}
                    getData={getData}
                    setData={setData}
                    setChoiceData={setChoiceData}
                    index={index}
                    choiceSet={choiceSet}
                    fieldUuid={fieldUuid}
                />
            </div>);
        }
    }

    return (
        <div>
            {choiceSets.map((choiceSet, index, list) => renderChoiceSet(choiceSet, index, list))}
        </div>
    );
}

const RenderChoiceSetInput = (props) => {
    const {
        name,
        locales,
        fetchUrl,
        selectedChoicesValue: selectedChoicesValueProps,
        setChoiceData,
        index,
        choiceSet,
        fieldUuid
    } = props

    const [selectedChoices, setSelectedChoices] = useState({BC: false, value: selectedChoicesValueProps})

    const [choices, setChoices] = useState([])
    const [loadingMessage, setLoadingMessage] = useState(Translations.messages['active_record.loading'])
    const [isInitialized, setIsInitialized] = useState(false)
    const [optionsList, setOptionsList] = useState([])
    const [modalIndex, setModalIndex] = useState(1)
    const [modalOpen, setModalOpen] = useState(false)

    useEffect(() => {
        setModalIndex(modalIndex + 1)
    }, [selectedChoices])

    function updateChoiceData(arr) {
        setChoiceData(index, arr.map(i => i.toString()));
    }

    function _getJSONFilter(choice) {
        return {value: choice.id, label: choice.name};
    }

    function selectChoice(value) {
        setSelectedChoices({...selectedChoices, value: value});
        if (value?.length) {
            updateChoiceData(value.map(v => v.value))
        } else {
            updateChoiceData([])
        }
    }

    function _getFilterOptions(providedChoices = false) {
        let computedChoices = providedChoices ? providedChoices : choices
        computedChoices = computedChoices.map(choice =>
            _getJSONFilter(choice)
        );

        return computedChoices;
    }

    async function _loadOptions(search, loadedOptions, {page}) {
        if (optionsList.length < 25 && isInitialized) {
            if (search.length > 0) {
                let regexExp = new RegExp(search, 'i')

                let choices = optionsList.filter(function (choice) {
                    return choice.label !== null && choice.label.match(regexExp) !== null && choice.label.match(regexExp).length > 0
                });
                return {
                    options: choices,
                    hasMore: false,
                    additional: {
                        page: page + 1,
                    },
                };
            }
            return {
                options: _getFilterOptions(),
                hasMore: choices.length === 25,
                additional: {
                    page: page + 1,
                },
            };
        }


        const res = await axios.get(`${fetchUrl}&search=${search}&page=${page}`)

        if (!isInitialized) {
            setChoices(res.data.choices)
            setLoadingMessage(res.data.loading_message)
            setOptionsList(res.data.choices.map(choice => _getJSONFilter(choice)))
            // setIsInitialized(search.length === 0)

            return {
                options: _getFilterOptions(res.data.choices),
                hasMore: res.data.hasMore,
                additional: {
                    page: page + 1,
                },
            };
        }
    }

    return (
        <div>
            <div className="dateTimeInput  row rails-bootstrap-forms-datetime-select" style={{display: 'flex'}}>
                <div className="col-sm-8">
                    <div style={{width: '100%'}}>
                        <AsyncPaginate
                            className="datation-filter"
                            delimiter=","
                            loadOptions={_loadOptions}
                            debounceTimeout={800}
                            isSearchable={true}
                            isClearable={true}
                            isMulti={true}
                            loadingMessage={() => loadingMessage}
                            additional={{
                                page: 1,
                            }}
                            styles={{menuPortal: base => ({...base, zIndex: 9999})}}
                            name="choices"
                            value={selectedChoices.value}
                            onChange={selectChoice}
                            options={optionsList}
                        />
                    </div>
                </div>
                <div className="col-sm-4">
                    <a onClick={() => setModalOpen(true)} className="btn btn-sm btn-outline-secondary"
                       data-toggle="modal"
                       data-target={"#choice-modal-" + fieldUuid + choiceSet.uuid} href="#">
                        <i className="fa fa-plus"></i>
                    </a>
                </div>
            </div>
            {modalOpen && (
                <ModalForm name={name}
                           locales={locales}
                           key={modalIndex}
                           modalIndex={modalIndex}
                           modalOpen={modalOpen}
                           setModalOpen={setModalOpen}
                           choiceSet={choiceSet}
                           fieldUuid={fieldUuid}
                           _getJSONFilter={_getJSONFilter}
                           selectedChoices={selectedChoices}
                           selectChoice={selectChoice}/>
            )}
        </div>
    )
}

const ModalForm = (props) => {
    const {
        locales,
        modalIndex,
        name,
        choiceSet,
        fieldUuid,
        _getJSONFilter,
        selectedChoices,
        selectChoice,
        modalOpen,
        setModalOpen
    } = props

    const [modalChoices, setModalChoices] = useState([])

    useEffect(() => {
        async function fetchData() {
            const response = await axios.get(choiceSet.newChoiceModalUrl)
            setModalChoices(response.data.choices)
        }

        fetchData()
    }, [])


    const [errorMsg, setErrorMsg] = useState('')
    const [errorChoice, setErrorChoice] = useState('')

    const handleSubmit = async (event) => {
        event.preventDefault();

        let form = event.target
        let params = '';
        for (let i = 0; i < form.elements.length; i++) {
            let fieldName = form.elements[i].name;
            let fieldValue = form.elements[i].value;

            params += fieldName + '=' + fieldValue + '&';
        }
        params += 'react' + '=' + 'true' + '&';

        try {
            axios.defaults.headers.common["X-CSRF-Token"] = (document.querySelector("meta[name=csrf-token]") || {}).content;
            axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
            axios.defaults.headers.common["content-type"] = 'application/x-www-form-urlencoded;charset=utf-8'

            const response = await axios.post(choiceSet.createChoiceUrl, params)

            if (response && response.data && response.data.choice_json_attributes) {
                selectChoice([...selectedChoices.value, _getJSONFilter(response.data.choice_json_attributes)])
                $(event.target).closest('div.modal').modal('hide')
                setErrorMsg('')
                setErrorChoice(false)
                setModalOpen(false)
            }
        } catch (error) {
            setErrorMsg(error.response.data.errors)
            setErrorChoice(error.response.data.choice)
        }
    }

    if (!modalOpen) {
        return ''
    } else {

        return (
            <div className="modal fade" id={"choice-modal-" + fieldUuid + choiceSet.uuid} tabIndex="-1" role="dialog"
                 data-field-uuid={fieldUuid + choiceSet.uuid} data-lang="fr" aria-labelledby="myModalLabel">
                <div className="modal-dialog">
                    <div className="modal-content">
                        <form onSubmit={handleSubmit} id={`new_choice_${choiceSet.id}`}>
                            <div className="modal-header">
                                <h4 className="modal-title">{Translations.messages['catalog_admin.choice_sets.choice_modal.create_new_field']} «{name}» </h4>
                                <button type="button" className="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">×</span>
                                </button>
                            </div>
                            <div className="modal-body">
                                <div className="card-body">
                                    <div className="mb-4">
                                        <div className="form-group">
                                            <label htmlFor="choice_parent_id">Parent</label>
                                            <select className="form-control" name="choice[parent_id]"
                                                    id="choice_parent_id">
                                                <option value=""></option>
                                                {modalChoices && modalChoices.map(o => {
                                                    return (
                                                        <option key={o.id} value={o.id}>{o.name}</option>
                                                    )
                                                })}
                                            </select>
                                        </div>
                                    </div>
                                    <div className="mb-4">
                                        <div className="form-group"><
                                            label htmlFor="choice_position">Position</label>
                                            <select className="form-control" name="choice[position]"
                                                    id="choice_position">
                                                <option
                                                    value="first">{Translations.messages['catalog_admin.choice_sets.choice_modal.position.first']}</option>
                                                <option
                                                    value="last">{Translations.messages['catalog_admin.choice_sets.choice_modal.position.last']}</option>
                                            </select>
                                        </div>
                                    </div>

                                    {locales.map((locale, idx) => (
                                        <div key={idx}>

                                            <div className="form-group">
                                                <label
                                                    htmlFor={`choice_short_name_${locale}`}>{Translations.messages['catalog_admin.choices.choice_fields.short_name']}</label>
                                                <div className="form-group">
                                                    <label className="sr-only required"
                                                           htmlFor={`choice_short_name_${locale}`}>{Translations.messages['catalog_admin.choices.choice_fields.short_name']}</label>
                                                    <input className="form-control" type="text"
                                                           name={`choice[short_name_${locale}]`}
                                                           id={`choice_short_name_${locale}`}/>
                                                </div>
                                            </div>
                                            <div className="form-group">
                                                <label
                                                    htmlFor={`choice_long_name_${locale}`}>{Translations.messages['catalog_admin.choices.choice_fields.long_name_optional']}</label>
                                                <div className="form-group">
                                                    <label className="sr-only"
                                                           htmlFor={`choice_long_name_${locale}`}>{Translations.messages['catalog_admin.choices.choice_fields.long_name_optional']}</label>
                                                    <input className="form-control" type="text"
                                                           name={`choice[long_name_${locale}]`}
                                                           id={`choice_long_name_${locale}`}/>
                                                </div>
                                            </div>
                                        </div>
                                    ))
                                    }

                                    <div className="form-group">
                                        <label
                                            htmlFor="choice_from_date">{Translations.messages['catalog_admin.choices.choice_fields.from_date']}</label>
                                        <input
                                            id={`from_date_${choiceSet.id}`}
                                            data-field-options={JSON.stringify({format: choiceSet.format})}
                                            data-field-required="true" autoComplete="off" type="hidden"
                                            name="choice[from_date]"
                                            value={errorChoice && errorChoice.from_date || JSON.stringify({
                                                Y: '',
                                                M: '',
                                                D: '',
                                                h: '',
                                                m: '',
                                                s: ''
                                            })}/>
                                        <DateTimeInput
                                            key={modalIndex}
                                            input={`#from_date_${choiceSet.id}`}
                                            allowBC={choiceSet.allowBC}
                                            preventNegativeInput={true}
                                        />
                                    </div>
                                    <div className="form-group">
                                        <label
                                            htmlFor="choice_to_date">{Translations.messages['catalog_admin.choices.choice_fields.to_date']}</label>
                                        <input
                                            id={`to_date_${choiceSet.id}`}
                                            data-field-options={JSON.stringify({format: choiceSet.format})}
                                            data-field-required="true" autoComplete="off" type="hidden"
                                            name="choice[to_date]"
                                            value={errorChoice && errorChoice.to_date || JSON.stringify({
                                                Y: '',
                                                M: '',
                                                D: '',
                                                h: '',
                                                m: '',
                                                s: ''
                                            })}/>
                                        <DateTimeInput
                                            key={modalIndex}
                                            input={`#to_date_${choiceSet.id}`}
                                            allowBC={choiceSet.allowBC}
                                            preventNegativeInput={true}
                                        />
                                    </div>
                                    <div className="base-errors">
                                        {errorMsg}
                                    </div>

                                </div>
                            </div>
                            <div className="modal-footer">
                                <button type="button" className="btn btn-outline-secondary"
                                        data-dismiss="modal">{Translations.messages['cancel']}</button>
                                <input type="submit" name="commit" value={Translations.messages['.create']}
                                       className="btn btn-success" data-disable-with={Translations.messages['create']}/>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        )
    }
}