import 'es6-shim';
import PropTypes from 'prop-types';
import React, {useState, useEffect} from 'react';
import Translations from '../../Translations/components/Translations';
import AsyncPaginate from 'react-select-async-paginate';
import axios from "axios";
import Validation from "../module/validation"

const ChoiceSetInput = (props) => {
    const {
        input,
        req,
        choiceSet: choiceSetProps,
        locales,
        fieldUuid
    } = props

    const [choiceSet, _setChoiceSets] = useState(choiceSetProps)
    const [choiceData, _setChoiceData] = useState(choiceSetProps.selectedChoicesValue.map(s => s.value))
    const [isValid, setIsValid] = useState(Validation.isValid(
      req,
      input
    ))

    const setChoiceData = (index, value) => {
        let data = choiceData
        data[index] = value
        _setChoiceData(data)
        setData(data[0])
    }

    function getData() {
        const value = getInput().val();
        if (!value) return '';
        return value.split(',');
    }

    function setData(d) {
        getInput().val(JSON.stringify(d));
        setIsValid(Validation.isValid(
            req,
            input
          )
        )
    }

    function getInput() {
        return $(input);
    }

    if (!(Object.keys(choiceSet).length > 0)) {
        return ''
    }

    return (
        <div>
            <div key={choiceSet.fetchUrl} className="mt-2">
                <RenderChoiceSetInput
                    locales={locales}
                    name={choiceSet.name}
                    fetchUrl={choiceSet.fetchUrl}
                    selectedChoicesValue={choiceSet.selectedChoicesValue}
                    getData={getData}
                    setData={setData}
                    setChoiceData={setChoiceData}
                    index={0}
                    choiceSet={choiceSet}
                    fieldUuid={fieldUuid}
                    getInput={getInput}
                    req={req}
                    input={input}
                />
            </div>
        </div>
    );
}

ChoiceSetInput.propTypes = {
    input: PropTypes.string.isRequired,
}

export default ChoiceSetInput;

const RenderChoiceSetInput = (props) => {
    const {
        locales,
        name,
        fetchUrl,
        selectedChoicesValue: selectedChoicesValueProps,
        setChoiceData,
        index,
        choiceSet,
        fieldUuid,
        getInput,
        req,
        input
    } = props

    const [selectedChoices, setSelectedChoices] = useState({value: selectedChoicesValueProps})

    const [choices, setChoices] = useState([])
    const [loadingMessage, setLoadingMessage] = useState(Translations.messages['loading'])
    const [noOptionsMessage, setNoOptionsMessage] = useState(Translations.messages['no_options'])
    const [placeHolderMessage, setPlaceHolderMessage] = useState(Translations.messages['select_placeholder'])
    const [isInitialized, _setIsInitialized] = useState(false)
    const [optionsList, setOptionsList] = useState([])
    const [modalIndex, setModalIndex] = useState(1)
    const [modalOpen, setModalOpen] = useState(false)

    useEffect(() => {
        setModalIndex(modalIndex + 1)
    }, [selectedChoices])


    useEffect(() => {
        updateInputCategoryDataAttributes(choiceSet.selectedChoicesValue)
    }, [choiceSet])

    function updateChoiceData(arr) {
        if (Array.isArray(arr)) {
            setChoiceData(index, arr.map(i => i.toString()));
        } else {
            setChoiceData(index, [arr.toString()]);
        }
    }

    function _getJSONFilter(choice) {
        return {
            value: choice.id,
            label: choice.name,
            category_id: choice.category_id,
            id: choice.id,
            choice_set_id: choice.choice_set_id
        };
    }

    function updateInputCategoryDataAttributes(choices) {
        let form = getInput().parents('form:first')
        form.find(`[data-field-category][data-field-category-choice-set-id=${choiceSet.id}]`).parent(".form-group").hide()
        form.find(`[data-field-category][data-field-category-choice-set-id=${choiceSet.id}]`).closest(".form-component").hide()
        if (choices && Array.isArray(choices)) {
            choices.forEach(choice => {
                form.find(`[data-field-category=${choice.category_id}][data-field-category-choice-id=${choice.id}][data-field-category-choice-set-id=${choice.choice_set_id}]`).parent(".form-group").show()
                form.find(`[data-field-category=${choice.category_id}][data-field-category-choice-id=${choice.id}][data-field-category-choice-set-id=${choice.choice_set_id}]`).closest(".form-component").show()
            })
        }
    }

    function selectChoice(value) {
        setSelectedChoices({...selectedChoices, value: value});
        if (value?.length || value) {
            updateChoiceData(Array.isArray(value) ? value.map(v => v.value) : value.value)
            updateInputCategoryDataAttributes(Array.isArray(value) ? value : [value])
        } else {
            updateChoiceData([])
            updateInputCategoryDataAttributes()
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
            <div className="choiceSetInput row" style={{display: 'flex'}}>
                <div className="col-sm-8">
                    <div className="choiceSetSelect"
                         style={Validation.getStyle(req, input)}>
                        <AsyncPaginate
                            delimiter=","
                            loadOptions={_loadOptions}
                            debounceTimeout={800}
                            isSearchable={true}
                            isClearable={true}
                            isMulti={choiceSet.multiple}
                            loadingMessage={() => loadingMessage}
                            searchingMessage={() => loadingMessage}
                            placeholder={ placeHolderMessage }
                            noOptionsMessage={() => noOptionsMessage}
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
                       data-target={"#choice-modal-" + fieldUuid} href="#">
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
    const [modalCategories, setModalCategories] = useState([])
    const [errorChoice, setErrorChoice] = useState('')

    useEffect(() => {
        if (modalOpen == true) {
            async function fetchData() {
                const response = await axios.get(choiceSet.newChoiceModalUrl)
                setModalChoices(response.data.choices)
                setModalCategories(response.data.categories)
            }

            fetchData()
        }
    }, [modalOpen])


    const [errorMsg, setErrorMsg] = useState('')

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
                if (choiceSet.multiple) {
                    selectChoice([...selectedChoices.value, _getJSONFilter(response.data.choice_json_attributes)])
                } else {
                    selectChoice([_getJSONFilter(response.data.choice_json_attributes)])
                }
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
            <div className="modal fade" id={"choice-modal-" + fieldUuid} tabIndex="-1" role="dialog"
                 data-field-uuid={fieldUuid} data-lang="fr" aria-labelledby="myModalLabel">
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
                                                })
                                                }
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

                                    {
                                        locales.map((locale, idx) => (
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
                                            htmlFor="choice_category_id">{Translations.messages['catalog_admin.choices.choice_fields.category_optional']}</label>
                                        <select className="form-control" name="choice[category_id]"
                                                id="choice_category_id">
                                            <option value="" label=" "></option>
                                            {modalCategories && modalCategories.map((category, idx) => (
                                                <option key={idx} value={category[0]}>{category[1]}</option>
                                            ))}
                                        </select>
                                    </div>

                                    <div className="base-errors">
                                        {errorMsg}
                                    </div>

                                </div>
                            </div>
                            <div className="modal-footer">
                                <button type="button" className="btn btn-outline-secondary"
                                        data-dismiss="modal">{Translations.messages["cancel"]}</button>
                                <input type="submit" name="commit" value={Translations.messages["create"]}
                                       className="btn btn-success"
                                       data-disable-with={Translations.messages["create"]}/>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        )
    }
}