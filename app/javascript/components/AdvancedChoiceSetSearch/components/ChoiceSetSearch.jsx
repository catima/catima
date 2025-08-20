import React, { useState, useMemo, useRef, useCallback } from 'react';
import ReactSelect from 'react-select';
import LinkedCategoryInput from './LinkedCategoryInput';
import AsyncPaginate from 'react-select-async-paginate';
import axios from "axios";
import Translations from "../../Translations/components/Translations";

// Default configuration for HTTP requests.
const HTTP_CONFIG = {
  retry: 3,
  retryDelay: 1000,
};

const getCategoryOptions = (itemData, locale) => {
  return itemData?.map(item => ({
    value: item.uuid,
    label: item.name_translations['name_' + locale],
    key: item.id,
    choiceSetId: item.field_set_id,
  })) || [];
};

const ChoiceSetSearch = (props) => {
  const {
    fieldUuid,
    itemId,
    choiceSet,
    catalog,
    searchPlaceholder,
    filterPlaceholder,
    fieldConditionData,
    defaultValues,
    locale,
    childChoicesActivatedPlaceholder,
    childChoicesActivatedYesLabel,
    childChoicesActivatedNoLabel,
    addComponent,
    deleteComponent,
    canAddComponent,
    canRemoveComponent,
  } = props

  const [selectedCondition, setSelectedCondition] = useState('')
  const [selectCondition, setSelectCondition] = useState([])
  const [selectedFieldCondition, setSelectedFieldCondition] = useState(defaultValues?.field_condition || '')
  const [selectedCategory, setSelectedCategory] = useState(null)
  const [selectedItem, setSelectedItem] = useState([])
  const [linkedCategoryData, setLinkedCategoryData] = useState({
    inputData: null,
    inputType: 'Field::Text',
    dateFormat: '',
    localizedDateTimeData: [],
    isLoading: false
  });

  const isFirstLoadOptionsRef = useRef(true);

  const buildInputNameWithCondition = useMemo(() => {
    const currentCondition = selectedCondition || 'default';
    return `advanced_search[criteria][${fieldUuid}][${itemId}][${currentCondition}]`;
  }, [fieldUuid, selectedCondition, itemId]);

  const categoryOptions = useMemo(() => {
    return getCategoryOptions(selectedItem?.data, locale);
  }, [selectedItem?.data, locale]);

  const clearCategory = useCallback(() => {
    setSelectedCategory(null);
    setSelectedCondition('');
    setSelectCondition([]);
    setLinkedCategoryData({
      inputData: null,
      inputType: 'Field::Text',
      dateFormat: '',
      localizedDateTimeData: [],
      isLoading: false
    });
  }, []);

  const fetchLinkedCategoryData = useCallback(async (category, defaultCondition = '') => {
    if (!category || !category.choiceSetId || !category.value) {
      return;
    }

    setLinkedCategoryData(prev => ({ ...prev, isLoading: true }));

    try {
      const url = `/react/${catalog}/${locale}/categories/${category.choiceSetId}/${category.value}`;
      const response = await axios.get(url, HTTP_CONFIG);
      const { data } = response;

      const formatOption = data.inputOptions?.find(option => option && 'format' in option);
      const localizedOption = data.inputOptions?.find(option => option && 'localizedDateTimeData' in option);

      setLinkedCategoryData({
        inputData: data.inputData || [],
        inputType: data.inputType || 'Field::Text',
        dateFormat: formatOption ? formatOption.format : '',
        localizedDateTimeData: localizedOption ? localizedOption.localizedDateTimeData : [],
        isLoading: false
      });

      if (data.selectCondition?.length > 0) {
        const existsInNewVal = data.selectCondition.find(item => item.key === defaultCondition);
        setSelectedCondition(existsInNewVal ? defaultCondition : data.selectCondition[0].key);
        setSelectCondition(data.selectCondition);
      }

    } catch (error) {
      console.error('Erreur lors de la récupération des données:', error);
      setLinkedCategoryData(prev => ({ ...prev, isLoading: false }));
    }
  }, [catalog, locale]);

  function selectItem(item) {
    if (!item || item.data.length === 0) {
        clearCategory();
    }
    setSelectedItem(item || []);
  }

  function handleSelectCategoryChange(category) {
    if (!category) {
        clearCategory();
    } else {
        setSelectedCategory(category);
        fetchLinkedCategoryData(category);
    }
  }

  async function loadOptions(search, loadedOptions, { page }) {
    // If the selected ChoiceSet is not active (deactivated
    // or deleted), then return an empty list of options.
    if (choiceSet.deactivated_at || choiceSet.deleted_at) {
      return {
        options: [],
        hasMore: false,
        additional: {
          page: page,
        },
      };
    }

    const defaultSelectedItem = defaultValues?.[defaultValues.condition || "default"];

    let url = `${choiceSet.fetchUrl}&page=${page}`;
    if (isFirstLoadOptionsRef.current && defaultSelectedItem) {
      url += `&default=${defaultSelectedItem}`;
    } else {
      url += `&search=${search}`;
    }

    const res = await axios.get(url);
    const options = res.data.choices.map(choice => ({
      value: choice.key,
      label: choice.label,
      data: choice.category_data || [],
      has_childrens: choice.has_childrens,
    }));

    // The first time we load the options, we want to select the default item
    // if specified.
    if (isFirstLoadOptionsRef.current) {
      isFirstLoadOptionsRef.current = false;

      const _selectedItem = options.find(item => item.value == defaultSelectedItem);
      if (_selectedItem) {
        selectItem(_selectedItem);
        setSelectCondition([]);
        setSelectedCondition(defaultValues?.condition || '');

        const defaultCategory = getCategoryOptions(
          _selectedItem?.data, locale,
        ).find((item) => item.value === defaultValues?.category_field);

        if (defaultCategory) {
          setSelectedCategory(defaultCategory);
          fetchLinkedCategoryData(defaultCategory, defaultValues?.condition || '');
        }
      }
    }

    return {
      options,
      hasMore: res.data.hasMore,
      additional: {
        page: page + 1,
      },
    };
  }

  function renderConditionElement() {
    return (
      <select
        className="form-select filter-condition"
        name={`advanced_search[criteria][${fieldUuid}][${itemId}][condition]`}
        value={selectedCondition}
        onChange={e => setSelectedCondition(e.target.value || '')}
        disabled={!selectedCategory}
      >
      {selectCondition.map((item) => (
        <option key={item.key} value={item.key}>{item.value}</option>
      ))}
      </select>
    );
  }

  function renderFieldConditionElement() {
    return (
      <select
        className="form-select filter-condition"
        name={`advanced_search[criteria][${fieldUuid}][${itemId}][field_condition]`}
        value={selectedFieldCondition}
        onChange={e => setSelectedFieldCondition(e.target.value || '')}
      >
        {fieldConditionData.map((item) => {
          return <option key={item.key} value={item.key}>{item.value}</option>
        })}
      </select>
    );
  }

  function renderChoiceSetElement() {
    return (
      <div>
        <AsyncPaginate
          defaultOptions={!!defaultValues[defaultValues.condition || "default"]}
          name={buildInputNameWithCondition}
          className={"basic-multi-select"}
          delimiter=","
          loadOptions={loadOptions}
          debounceTimeout={800}
          isSearchable={true}
          isClearable={true}
          isMulti={false}
          loadingMessage={() => searchPlaceholder}
          searchingMessage={() => searchPlaceholder}
          placeholder={Translations.messages['select_placeholder']}
          noOptionsMessage={() => Translations.messages['no_options']}
          additional={{
            page: 1,
          }}
          styles={{ menuPortal: base => ({ ...base, zIndex: 9999 }) }}
          onChange={selectItem}
          value={selectedItem}
        />
      </div>
    );
  }

  function renderCategoryElement(categoryOptions) {

    return (
      <ReactSelect
        name={`advanced_search[criteria][${fieldUuid}][${itemId}][category_field]`}
        options={categoryOptions}
        className="basic-multi-select"
        onChange={handleSelectCategoryChange}
        classNamePrefix="select"
        placeholder={filterPlaceholder}
        isClearable={true}
        value={selectedCategory}
      />
    );
  }

  function renderChildChoicesElement() {
    const childChoices = [
      { value: true, label: childChoicesActivatedYesLabel },
      { value: false, label: childChoicesActivatedNoLabel },
    ];
    const isChildChoicesActivated = defaultValues["child_choices_activated"] && defaultValues["child_choices_activated"] === "true";

    const defaultValue = childChoices.find(
      (item) => item.value === isChildChoicesActivated,
    );

    return (
      <ReactSelect name={`advanced_search[criteria][${fieldUuid}][${itemId}][child_choices_activated]`}
        options={childChoices}
        classNamePrefix="select"
        placeholder={childChoicesActivatedPlaceholder}
        defaultValue={defaultValue}
      />
    );
  }

  function renderLinkedCategoryElement() {
    return (
      <div>
        <LinkedCategoryInput
          fieldUuid={fieldUuid}
          itemId={itemId}
          locale={locale}
          selectedCondition={selectedCondition}
          searchPlaceholder={searchPlaceholder}
          defaultValue={defaultValues}
          linkedCategoryData={linkedCategoryData}
        />
      </div>
    );
  }

  return (
    <div className="col-lg-12 choiceset-search-container choiceSetInput">
      <div className="row">
        <div className="col-lg-2">
          {renderFieldConditionElement()}
        </div>
        <div className={categoryOptions.length > 0 || selectedItem?.has_childrens ? 'col-lg-3' : 'col-lg-6'}>
          {renderChoiceSetElement()}
        </div>
        {(selectedItem?.has_childrens) &&
          <div className="col-lg-3">
            {renderChildChoicesElement()}
          </div>
        }
        {(categoryOptions.length > 0) &&
          <div className="col-lg-3">
            {renderCategoryElement(categoryOptions)}
          </div>
        }
        <div className="col-lg-1">
          <div className="row">
            {canAddComponent &&
              <div className="col-lg-12">
                <a type="button" onClick={addComponent}>
                  <i className="fa fa-plus"></i>
                </a>
              </div>
            }
            {canRemoveComponent &&
              <div className="col-lg-12">
                <a type="button" onClick={deleteComponent}>
                  <i className="fa fa-trash"></i>
                </a>
              </div>
            }
          </div>
        </div>
        {!(selectedItem?.has_childrens && categoryOptions.length > 0) &&
          <div className="col-lg-3">
            {renderConditionElement()}
          </div>
        }
      </div>
      <div className="row">
        {(selectedItem?.has_childrens && categoryOptions.length > 0) &&
          <div className="col-lg-3" style={{ marginTop: '10px' }}>
            {renderConditionElement()}
          </div>
        }
        {selectedCategory &&
          <div className="col-lg-offset-2 col-lg-6">
            {renderLinkedCategoryElement()}
          </div>
        }
      </div>
    </div>
  );
}

export default ChoiceSetSearch;
