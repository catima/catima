import React, { useState, useMemo, useRef } from 'react';
import ReactSelect from 'react-select';
import ItemTypeReference from './partials/ItemTypeReference';
import AsyncPaginate from 'react-select-async-paginate';
import axios from "axios";
import Translations from "../../Translations/components/Translations";
import ChildChoicesElement from './partials/ChildChoicesElement';
import ActionButtons from './partials/ActionButtons';

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

const ConditionSelectElement = ({ selectCondition, selectedCondition, setSelectedCondition, fieldUuid, itemId, selectedCategory }) => (
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

const FieldConditionSelectElement = ({ fieldConditionData, selectedFieldCondition, setSelectedFieldCondition, fieldUuid, itemId }) => (
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

const ChoiceSetSelectElement = ({ buildInputNameWithCondition, defaultValues, choiceSet, loadOptions, selectItem, selectedItem }) => (
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
      loadingMessage={() => Translations.messages['advanced_searches.fields.choice_set_search_field.select_placeholder']}
      searchingMessage={() => Translations.messages['advanced_searches.fields.choice_set_search_field.select_placeholder']}
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

const CategorySelectElement = ({ categoryOptions, handleSelectCategoryChange, selectedCategory, fieldUuid, itemId }) => (
  <ReactSelect
    name={`advanced_search[criteria][${fieldUuid}][${itemId}][category_field]`}
    options={categoryOptions}
    className="basic-multi-select"
    onChange={handleSelectCategoryChange}
    classNamePrefix="select"
    placeholder={Translations.messages['advanced_searches.fields.choice_set_search_field.filter_placeholder']}
    isClearable={true}
    value={selectedCategory}
  />
);

const ChildChoicesContainerElement = ({ fieldUuid, itemId, defaultValues }) => (
  <ChildChoicesElement
    fieldUuid={fieldUuid}
    itemId={itemId}
    defaultValues={defaultValues}
  />
);

const LinkedCategoryElement = ({ fieldUuid, itemId, locale, selectedCondition, defaultValues, linkedCategoryData }) => (
  <div>
    <ItemTypeReference
      fieldUuid={fieldUuid}
      itemId={itemId}
      locale={locale}
      selectedCondition={selectedCondition}
      defaultValues={defaultValues}
      fetchedData={linkedCategoryData}
      isFromCategory={true}
    />
  </div>
);

const ChoiceSet = (props) => {
  const {
    fieldUuid,
    itemId,
    choiceSet,
    catalog,
    fieldConditionData,
    defaultValues,
    locale,
    addComponent,
    deleteComponent,
    canAddComponent,
    canRemoveComponent,
  } = props

  const [selectedCondition, setSelectedCondition] = useState('');
  const [selectCondition, setSelectCondition] = useState([]);
  const [selectedFieldCondition, setSelectedFieldCondition] = useState(defaultValues?.field_condition || '');
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [selectedItem, setSelectedItem] = useState([]);
  const [linkedCategoryData, setLinkedCategoryData] = useState({
    inputData: null,
    inputType: 'Field::Text',
    dateFormat: '',
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

  const clearCategory = () => {
    setSelectedCategory(null);
    setSelectedCondition('');
    setSelectCondition([]);
    setLinkedCategoryData({
      inputData: null,
      inputType: 'Field::Text',
      dateFormat: '',
      isLoading: false
    });
  };

  const fetchLinkedCategoryData = async (category, defaultCondition = '') => {
    if (!category || !category.choiceSetId || !category.value) {
      return;
    }

    setLinkedCategoryData(prev => ({ ...prev, isLoading: true }));

    try {
      const url = `/react/${catalog}/${locale}/categories/${category.choiceSetId}/${category.value}`;
      const response = await axios.get(url, HTTP_CONFIG);
      const { data } = response;

      const formatOption = data.inputOptions?.find(option => option && 'format' in option);

      setLinkedCategoryData({
        inputData: data.inputData || [],
        inputType: data.inputType || 'Field::Text',
        dateFormat: formatOption ? formatOption.format : '',
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
  };

  const selectItem = (item) => {
    if (!item || item.data.length === 0) {
      clearCategory();
    }
    setSelectedItem(item || []);
  };

  const handleSelectCategoryChange = (category) => {
    if (!category) {
      clearCategory();
    } else {
      setSelectedCategory(category);
      fetchLinkedCategoryData(category);
    }
  };

  const loadOptions = async (search, loadedOptions, { page }) => {
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
  };

  return (
    <div className="col-lg-12 choiceset-search-container choiceSetInput">
      <div className="row">
        <div className="col-lg-2">
          <FieldConditionSelectElement
            fieldConditionData={fieldConditionData}
            selectedFieldCondition={selectedFieldCondition}
            setSelectedFieldCondition={setSelectedFieldCondition}
            fieldUuid={fieldUuid}
            itemId={itemId}
          />
        </div>
        <div className={selectedItem?.has_childrens ? 'col-lg-3' : 'col-lg-6'}>
          <ChoiceSetSelectElement
            buildInputNameWithCondition={buildInputNameWithCondition}
            defaultValues={defaultValues}
            choiceSet={choiceSet}
            loadOptions={loadOptions}
            selectItem={selectItem}
            selectedItem={selectedItem}
          />
        </div>
        {(selectedItem?.has_childrens) &&
          <div className="col-lg-3">
            <ChildChoicesContainerElement
              fieldUuid={fieldUuid}
              itemId={itemId}
              defaultValues={defaultValues}
            />
          </div>
        }
        <ActionButtons
          addComponent={addComponent}
          deleteComponent={deleteComponent}
          canAddComponent={canAddComponent}
          canRemoveComponent={canRemoveComponent}
        />
        <div className="col-lg-3">
          <ConditionSelectElement
            selectCondition={selectCondition}
            selectedCondition={selectedCondition}
            setSelectedCondition={setSelectedCondition}
            fieldUuid={fieldUuid}
            itemId={itemId}
            selectedCategory={selectedCategory}
          />
        </div>
      </div>
      <div className="row mt-2">
        {(categoryOptions.length > 0) &&
          <div className="col-lg-3 offset-lg-2">
            <CategorySelectElement
              categoryOptions={categoryOptions}
              handleSelectCategoryChange={handleSelectCategoryChange}
              selectedCategory={selectedCategory}
              fieldUuid={fieldUuid}
              itemId={itemId}
            />
          </div>
        }
        {selectedCategory &&
          <div className="col-lg-4">
            <LinkedCategoryElement
              fieldUuid={fieldUuid}
              itemId={itemId}
              locale={locale}
              selectedCondition={selectedCondition}
              defaultValues={defaultValues}
              linkedCategoryData={linkedCategoryData}
            />
          </div>
        }
      </div>
    </div>
  );
}

export default ChoiceSet;
