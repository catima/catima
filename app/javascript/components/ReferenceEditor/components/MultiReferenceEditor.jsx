import React, { useState, useEffect, useMemo, useCallback, useRef } from 'react';
import ReactSelect from 'react-select';
import striptags from 'striptags';
import LoadingDots from '../../StyleControl/components/LoadingDots';
import Validation from '../modules/validation';
import Translations from '../../Translations/components/Translations';
import { loadingDotsStyle, filterDropdownStyle } from '../modules/styles';

const WAIT_INTERVAL = 1000;

const MultiReferenceEditor = (props) => {
  const {
    selectedReferences,
    req,
    srcRef,
    itemsUrl,
    fields,
    srcId,
    searchPlaceholder,
    filterPlaceholder,
    noOptionsMessage,
    items: itemsProps,
  } = props;

  // State management
  const [availableItems, setAvailableItems] = useState(itemsProps);
  const [selectedItems, setSelectedItems] = useState(selectedReferences);
  const [highlightedAvailable, setHighlightedAvailable] = useState(new Set());
  const [highlightedSelected, setHighlightedSelected] = useState(new Set());
  const [availableFilter, setAvailableFilter] = useState(null);
  const [selectedFilter, setSelectedFilter] = useState(null);
  const [availableSearch, setAvailableSearch] = useState('');
  const [selectedSearch, setSelectedSearch] = useState('');
  const [loading, setLoading] = useState({ fetching: false, searching: false });
  const [pagination, setPagination] = useState({ page: 1, hasMore: true });

  const searchTimer = useRef(null);
  const editorId = `${srcRef}-editor`;

  // Memoized filter options
  const filterOptions = useMemo(() =>
    fields
      .filter(field => field.human_readable)
      .map(field => ({ value: field.slug, label: field.name })),
    [fields]
  );

  // Get item display name with filter
  const getItemName = useCallback((item, filter) => {
    const baseName = striptags(item.default_display_name);
    if (!filter || !item[filter.value]) {
      return baseName;
    }
    return `${baseName} - ${item[filter.value]}`;
  }, []);

  // Filter items based on search and availability
  const filteredAvailableItems = useMemo(() => {
    const selectedIds = new Set(selectedItems.map(item => item.id));
    return availableItems.filter(item => {
      if (selectedIds.has(item.id) || !item.default_display_name) return false;

      if (!availableSearch) return true;

      const itemName = getItemName(item, availableFilter).toLowerCase();
      return itemName.includes(availableSearch.toLowerCase());
    });
  }, [availableItems, selectedItems, availableSearch, availableFilter, getItemName]);

  const filteredSelectedItems = useMemo(() => {
    if (!selectedSearch) return selectedItems;

    return selectedItems.filter(item => {
      const itemName = getItemName(item, selectedFilter).toLowerCase();
      return itemName.includes(selectedSearch.toLowerCase());
    });
  }, [selectedItems, selectedSearch, selectedFilter, getItemName]);

  // Save to DOM and validate
  useEffect(() => {
    const domElement = document.getElementById(srcRef);
    if (domElement) {
      const value = JSON.stringify(selectedItems.map(item => item.id.toString()));
      domElement.value = value;
    }
  }, [selectedItems, srcRef]);

  // Fetch items from API
  const fetchItems = useCallback(async (search = '', page = 1, append = false) => {
    if (loading.fetching || (!pagination.hasMore && append)) return;

    // Local filtering for small datasets
    if (itemsProps.length < 25 && search) {
      const regex = new RegExp(search, 'i');
      const filtered = itemsProps.filter(item =>
        item.default_display_name && regex.test(item.default_display_name)
      );
      setAvailableItems(filtered);
      return;
    }

    setLoading(prev => ({ ...prev, fetching: true }));

    try {
      const selectedIds = selectedItems.map(item => item.id);
      const exceptParams = selectedIds.map(id => `except[]=${id}`).join('&');
      const url = `${itemsUrl}?search=${search}&page=${page}&${exceptParams}`;

      const response = await fetch(url);
      const data = await response.json();

      setAvailableItems(prev => append ? [...prev, ...data.items] : data.items);
      setPagination({ page, hasMore: data.items.length === 25 });
    } catch (error) {
      console.error('Failed to fetch items:', error);
    } finally {
      setLoading(prev => ({ ...prev, fetching: false }));
    }
  }, [loading.fetching, pagination.hasMore, itemsProps, itemsUrl, selectedItems]);

  // Debounced search
  const handleAvailableSearch = useCallback((e) => {
    const searchTerm = e.target.value;
    setAvailableSearch(searchTerm);
    setLoading(prev => ({ ...prev, searching: true }));

    clearTimeout(searchTimer.current);
    searchTimer.current = setTimeout(() => {
      fetchItems(searchTerm, 1, false);
      setLoading(prev => ({ ...prev, searching: false }));
    }, WAIT_INTERVAL);
  }, [fetchItems]);

  // Item selection handlers
  const toggleItemHighlight = useCallback((itemId, isAvailable) => {
    const setHighlighted = isAvailable ? setHighlightedAvailable : setHighlightedSelected;
    setHighlighted(prev => {
      const newSet = new Set(prev);
      if (newSet.has(itemId)) {
        newSet.delete(itemId);
      } else {
        newSet.add(itemId);
      }
      return newSet;
    });
  }, []);

  const selectItems = useCallback(() => {
    const itemsToAdd = availableItems.filter(item => highlightedAvailable.has(item.id));
    setSelectedItems(prev => [...prev, ...itemsToAdd]);
    setHighlightedAvailable(new Set());
  }, [availableItems, highlightedAvailable]);

  const unselectItems = useCallback(() => {
    setSelectedItems(prev => prev.filter(item => !highlightedSelected.has(item.id)));
    setHighlightedSelected(new Set());
  }, [highlightedSelected]);

  const loadMore = useCallback(() => {
    fetchItems(availableSearch, pagination.page + 1, true);
  }, [fetchItems, availableSearch, pagination.page]);

  // Item rendering
  const renderItem = useCallback((item, isHighlighted, onClick, filter) => (
    <div
      key={`${srcId}-${item.id}`}
      className={`item ${isHighlighted ? 'highlighted' : ''}`}
      onClick={() => onClick(item.id)}
    >
      {getItemName(item, filter)}
    </div>
  ), [srcId, getItemName]);

  const canSelectItems = highlightedAvailable.size > 0;
  const canUnselectItems = highlightedSelected.size > 0;
  const showLoadMore = pagination.hasMore && !loading.fetching && !loading.searching;

  return (
    <div
      className="multiple-reference-container"
      style={Validation.getStyle(req, srcRef, 'MultiReferenceEditor')}
    >
      <div id={editorId} className="wrapper">
        {/* Available References */}
        <div className="availableReferences">
          <div className="input-group">
            <input
              className="form-control"
              type="text"
              value={availableSearch}
              onChange={handleAvailableSearch}
              placeholder={searchPlaceholder}
            />
            <div style={{ paddingRight: 5 }}>
              {loading.searching && <LoadingDots />}
            </div>
            <div className="input-group-addon">
              <ReactSelect
                className="multiple-reference-filter"
                isSearchable={false}
                isClearable={true}
                value={availableFilter}
                onChange={setAvailableFilter}
                options={filterOptions}
                placeholder={filterPlaceholder}
                noOptionsMessage={noOptionsMessage}
                styles={filterDropdownStyle}
              />
            </div>
          </div>
          <div>
            {filteredAvailableItems.map(item =>
              renderItem(
                item,
                highlightedAvailable.has(item.id),
                (id) => toggleItemHighlight(id, true),
                availableFilter
              )
            )}
            {showLoadMore && (
              <div className="load-more" onClick={loadMore} style={{
                textAlign: "center",
                color: "#337ab7",
                cursor: "pointer",
                height: 40,
                paddingTop: 10,
                paddingBottom: 10
              }}>
                {Translations.messages['catalog_admin.fields.reference_editor.load_more']}
              </div>
            )}
            {loading.fetching && <LoadingDots />}
          </div>
        </div>

        {/* Control Buttons */}
        <div className="referenceControls">
          <button
            className={`btn btn-success ${!canSelectItems ? 'disabled' : ''}`}
            onClick={selectItems}
            disabled={!canSelectItems}
          >
            <i className="fa fa-arrow-right"></i>
          </button>
          <button
            className={`btn btn-danger ${!canUnselectItems ? 'disabled' : ''}`}
            onClick={unselectItems}
            disabled={!canUnselectItems}
          >
            <i className="fa fa-arrow-left"></i>
          </button>
        </div>

        {/* Selected References */}
        <div className="selectedReferences">
          <div className="input-group">
            <input
              className="form-control"
              type="text"
              value={selectedSearch}
              onChange={(e) => setSelectedSearch(e.target.value)}
              placeholder={searchPlaceholder}
            />
            <div className="input-group-addon">
              <ReactSelect
                className="multiple-reference-filter"
                isSearchable={false}
                isClearable={true}
                value={selectedFilter}
                onChange={setSelectedFilter}
                options={filterOptions}
                placeholder={filterPlaceholder}
                noOptionsMessage={noOptionsMessage}
                styles={filterDropdownStyle}
              />
            </div>
          </div>
          <div>
            {filteredSelectedItems.map(item =>
              renderItem(
                item,
                highlightedSelected.has(item.id),
                (id) => toggleItemHighlight(id, false),
                selectedFilter
              )
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default MultiReferenceEditor;
