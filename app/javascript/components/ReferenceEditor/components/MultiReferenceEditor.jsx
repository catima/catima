import React, {useState, useEffect, useRef} from 'react';
import axios from 'axios';
import ReactSelect from 'react-select';
import striptags from 'striptags';
import LoadingDots from '../../StyleControl/components/LoadingDots';
import Validation from "../modules/validation";
import {loadingDotsStyle, filterDropdownStyle} from '../modules/styles';

const WAIT_INTERVAL = 800;

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
  } = props

  const [items, setItems] = useState(itemsProps)
  const [page, setPage] = useState(1)
  const [loadMore, setLoadMore] = useState(true)
  const [isFetching, setIsFetching] = useState(false)
  const [isSearching, setIsSearching] = useState(false)
  const [selectedItems, setSelectedItems] = useState(selectedReferences.map((item) => item.id))
  const [selectedItemsToRender, setSelectedItemsToRender] = useState(selectedReferences)
  const [availableRefsSelectedFilter, setAvailableRefsSelectedFilter] = useState(null)
  const [selectedRefsSelectedFilter, setSelectedRefsSelectedFilter] = useState(null)
  const [filterAvailableInputValue, setFilterAvailableInputValue] = useState('')
  const [filterSelectedInputValue, setFilterSelectedInputValue] = useState('')
  const [isValid, setIsValid] = useState(Validation.isValid(
    req,
    srcRef,
    'MultiReferenceEditor'
  ))

  const timer = useRef(null)

  const editorId = `${srcRef}-editor`;
  const availableRefsFilterId = `${srcRef}-available-filters`;
  const selectedRefsFilterId = `${srcRef}-selected-filters`;

  useEffect(() => {
    if (items.length < 25) {
      setLoadMore(false)
    }
  }, [items])

  useEffect(() => {
    _save()
  }, [selectedItemsToRender, selectedItems])

  function _highlightItem(e) {
    e.target.classList.toggle('highlighted');
    updateButtonStatus();
  }

  function _selectItems() {
    const highItems = highlightedItems('availableReferences');
    let previouslySelectedItemsToRender = selectedItemsToRender;
    let newSelectedItems = [];
    setSelectedItemsToRender([]);
    highItems.forEach((item) => {
      let filteredItems = items.filter(it => it.id === item)
      if (filteredItems.length > 0) {
        newSelectedItems.push(filteredItems[0]);
      }
    });
    newSelectedItems = previouslySelectedItemsToRender.concat(newSelectedItems);
    setSelectedItems(selectedItems.concat(highItems))
    setSelectedItemsToRender(newSelectedItems)
  }

  function _unselectItems() {
    const highItems = highlightedItems('selectedReferences');
    let selectedItemsToRemove = [];
    highItems.forEach((item) => {
      let filteredItems = selectedItemsToRender.filter(it => it.id === item)
      if (filteredItems.length > 0) {
        selectedItemsToRemove.push(filteredItems[0]);
      }
    });
    setSelectedItemsToRender(selectedItemsToRender.filter(itm =>
      selectedItemsToRemove.indexOf(itm) === -1
    ))
    setSelectedItems(selectedItems.filter(itm =>
      highItems.indexOf(itm) === -1
    ))
  }

  const _fetchItems = async (search, pageArg) => {
    if (!isFetching && loadMore) {
      // Avoir useless API calls if there are less than 25 loaded items and the user searches
      if (items.length < 25 && search.length > 0) {
        let regexExp = new RegExp(search, 'i')
        setItems(
          items.filter(function (item) {
            return item.name !== null && item.name.match(regexExp) !== null && item.name.match(regexExp).length > 0
          })
        )

        return {
          options: this.getItemOptions(items),
          hasMore: false,
          additional: {
            page: pageArg,
          },
        };
      }

      let config = {
        retry: 3,
        retryDelay: 1000,
      };

      setIsFetching(true)

      if (filterAvailableInputValue === null) {
        setFilterAvailableInputValue('')
      }
      // http://localhost:3000/react/atlastopvaud/fr/toponymes?search=qsdf&page=1
      let currentPage = page + 1;
      let currentItems = items;
      let itemsUrlVar = `${itemsUrl}?search=${filterAvailableInputValue}&page=${currentPage}`
      selectedItems.forEach((itemId) => {
        itemsUrlVar = itemsUrlVar + `&except[]=${itemId}`
      });
      await axios.get(itemsUrlVar, config)
        .then(res => {
          setItems(currentItems.concat(res.data.items))
          setLoadMore(res.data.items.length === 25)
          setIsFetching(false)
          setPage(currentPage)
        });
    }
  }

  function _save() {
    updateButtonStatus();
    const v = JSON.stringify(
      selectedItems.map(v =>
        v.toString()
      )
    );
    document.getElementById(srcRef).value = v;

    setIsValid(Validation.isValid(
        req,
        srcRef,
        'MultiReferenceEditor'
      )
    )
  }

  function _availableRefsItemName(item) {
    // if(typeof this.state === 'undefined') return striptags(item.default_display_name);
    if ((availableRefsSelectedFilter === null
      || item[availableRefsSelectedFilter.value] === null
      || typeof item[availableRefsSelectedFilter.value] === 'undefined'
      || item[availableRefsSelectedFilter.value].length === 0)
    ) {
      return striptags(item.default_display_name);
    }
    return striptags(item.default_display_name) + ' - ' + item[availableRefsSelectedFilter.value];
  }

  function _selectedRefsItemName(item) {
    // if(typeof this.state === 'undefined') return striptags(item.default_display_name);
    if ((selectedRefsSelectedFilter === null
      || item[selectedRefsSelectedFilter.value] === null
      || typeof item[selectedRefsSelectedFilter.value] === 'undefined'
      || item[selectedRefsSelectedFilter.value].length === 0)
    ) {
      return striptags(item.default_display_name);
    }
    return striptags(item.default_display_name) + ' - ' + item[selectedRefsSelectedFilter.value];
  }

  function _selectButtonId(status) {
    return `${editorId}-${status}`;
  }

  function _availableRefsSelectFilter(filter) {
    setAvailableRefsSelectedFilter(filter);
  }

  function _selectedRefsSelectFilter(filter) {
    setSelectedRefsSelectedFilter(filter);
  }

  function _getFilterOptions() {
    let optionsList = [];
    optionsList = fields.filter(field => field.human_readable);

    optionsList = optionsList.map(field =>
      _getJSONFilter(field)
    );
    return optionsList;
  }

  function _getJSONFilter(field) {
    return {value: field.slug, label: field.name};
  }

  const _filterAvailableReferences = async (e) => {
    clearTimeout(timer.current);
    let searchTerm = e.target.value;
    if (searchTerm !== filterAvailableInputValue) {
      setLoadMore(true);
    }
    setFilterAvailableInputValue(searchTerm)
    setIsSearching(true)
    timer.current = setTimeout(() => {
      if (!isFetching) {
        let config = {
          retry: 3,
          retryDelay: 1000,
        };

        let currentPage = 1
        if (filterAvailableInputValue === null) {
          setFilterAvailableInputValue('');
        }
        let itemsUrlVar = `${itemsUrl}?search=${searchTerm}&page=${currentPage}`
        selectedItems.forEach((itemId) => {
          itemsUrlVar = itemsUrlVar + `&except[]=${itemId}`
        });

        axios.get(itemsUrlVar, config)
          .then(res => {
            setItems(res.data.items)
            setIsSearching(false)
          });
      }
    }, WAIT_INTERVAL);
  }

  function _filterSelectedReferences(e) {
    setFilterSelectedInputValue(e.target.value);
  }

  function highlightedItems(className) {
    return Array.prototype.map.call(
      document.querySelectorAll(`#${editorId} .${className} .item.highlighted`),
      itm =>
        parseInt(itm.id.split('-')[1])
    );
  }

  function updateButtonStatus() {
    if (highlightedItems('availableReferences').length > 0) {
      document.querySelector(`#${editorId} .referenceControls .btn-success`).removeAttribute('disabled');
      document.querySelector(`#${editorId} .referenceControls .btn-success`).classList.remove('disabled');
    } else {
      document.querySelector(`#${editorId} .referenceControls .btn-success`).setAttribute('disabled', 'disabled');
      document.querySelector(`#${editorId} .referenceControls .btn-success`).classList.add('disabled');
    }
    if (highlightedItems('selectedReferences').length > 0) {
      document.querySelector(`#${editorId} .referenceControls .btn-danger`).removeAttribute('disabled');
      document.querySelector(`#${editorId} .referenceControls .btn-danger`).classList.remove('disabled');
    } else {
      document.querySelector(`#${editorId} .referenceControls .btn-danger`).setAttribute('disabled', 'disabled');
      document.querySelector(`#${editorId} .referenceControls .btn-danger`).classList.add('disabled');
    }
  }

  const handleScroll = (e) => {
    const bottom = e.target.clientHeight - (e.target.scrollHeight - e.target.scrollTop) > -10;
    if (bottom) {
      if (!isFetching && loadMore) {
        _fetchItems();
      }
    }
  }

  function renderAvailableItemDiv(item, selectedItemsArg) {
    if (item.default_display_name === null) {
      return null;
    }
    const itemDivId = `${srcId}-${item.id}`;
    if (selectedItemsArg == false && selectedItems.indexOf(item.id) > -1) return null;
    if (selectedItemsArg == true && selectedItems.indexOf(item.id) == -1) return null;
    // Filtering the unselected items ItemList
    if (selectedItemsArg == false && filterAvailableInputValue !== '') {
      let isInString = -1;
      if (availableRefsSelectedFilter !== null) {
        if (item[availableRefsSelectedFilter.value] !== null && item[availableRefsSelectedFilter.value].length !== 0) {
          let searchString = item.default_display_name.toLowerCase() + ' - ' + JSON.stringify(item[availableRefsSelectedFilter.value]).toLowerCase();
          isInString = searchString.indexOf(filterAvailableInputValue.toLowerCase());
        } else {
          isInString = item.default_display_name.toLowerCase().indexOf(filterAvailableInputValue.toLowerCase());
        }
      } else {
        isInString = item.default_display_name.toLowerCase().indexOf(filterAvailableInputValue.toLowerCase());
      }
      if (isInString === -1) return null;
    }

    return (
      <div id={itemDivId} key={itemDivId} className="item" onClick={_highlightItem}>
        {_availableRefsItemName(item)}
      </div>
    );
  }

  function renderSelectedItemDiv(item) {
    const itemDivId = `${srcId}-${item.id}`;
    // Filtering the selected items ItemList
    if (filterSelectedInputValue !== '') {
      let isInString = -1;
      if (selectedRefsSelectedFilter !== null &&
        item[selectedRefsSelectedFilter.value] !== null &&
        item[selectedRefsSelectedFilter.value].length !== 0
      ) {
        let searchString = item.default_display_name.toLowerCase() + ' - ' + JSON.stringify(item[selectedRefsSelectedFilter.value]).toLowerCase();
        isInString = searchString.indexOf(filterSelectedInputValue.toLowerCase());
      } else {
        isInString = item.default_display_name.toLowerCase().indexOf(filterSelectedInputValue.toLowerCase());
      }
      if (isInString === -1) return null;
    }

    return (
      <div id={itemDivId} key={itemDivId} className="item" onClick={_highlightItem}>
        {_selectedRefsItemName(item)}
      </div>
    );
  }

  return (
    <div className="multiple-reference-container"
         style={Validation.getStyle(req, srcRef, 'MultiReferenceEditor')}
    >
      <div id={editorId} className="wrapper">
        <div className="availableReferences" onScroll={handleScroll}>
          <div className="input-group">

            <input
              className="form-control"
              type="text"
              value={filterAvailableInputValue}
              onChange={_filterAvailableReferences}
              placeholder={searchPlaceholder}/>

            {isSearching ? (
              <div className="input-group-addon" style={loadingDotsStyle}>
                <LoadingDots/>
              </div>) : ('')}

            <div className="input-group-addon">
              <ReactSelect
                id={availableRefsFilterId}
                className="multiple-reference-filter"
                isSearchable={false}
                isClearable={true}
                value={availableRefsSelectedFilter}
                onChange={_availableRefsSelectFilter}
                options={_getFilterOptions()}
                placeholder={filterPlaceholder}
                noOptionsMessage={noOptionsMessage}
                styles={filterDropdownStyle}
              />
            </div>
          </div>
          <div>
            {items.map(item =>
              renderAvailableItemDiv(item, false)
            )}
            {isFetching && <LoadingDots/>}
          </div>
        </div>
        <div className="referenceControls">
          <div id={_selectButtonId('select')} className="btn btn-success" onClick={_selectItems} disabled>
            <i className="fa fa-arrow-right"></i>
          </div>
          <div id={_selectButtonId('unselect')} className="btn btn-danger" onClick={_unselectItems} disabled>
            <i className="fa fa-arrow-left"></i>
          </div>
        </div>
        <div className="selectedReferences">
          <div className="input-group">
            <input className="form-control" type="text" value={filterSelectedInputValue}
                   onChange={_filterSelectedReferences} placeholder={searchPlaceholder}/>
            <div className="input-group-addon">
              <ReactSelect
                id={selectedRefsFilterId}
                className="multiple-reference-filter"
                isSearchable={false}
                isClearable={true}
                value={selectedRefsSelectedFilter}
                onChange={_selectedRefsSelectFilter}
                options={_getFilterOptions()}
                placeholder={filterPlaceholder}
                noOptionsMessage={noOptionsMessage}
                styles={filterDropdownStyle}
              />
            </div>
          </div>
          <div>
            {selectedItemsToRender.map(item =>
              renderSelectedItemDiv(item)
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default MultiReferenceEditor;
