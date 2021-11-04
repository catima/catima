import React, {useState, useLayoutEffect} from 'react';
import axios from 'axios';
import SingleReferenceEditor from './SingleReferenceEditor';
import MultiReferenceEditor from './MultiReferenceEditor';

const ReferenceEditor = (props) => {
  const {
    catalog,
    locale,
    itemType,
    noOptionsMessage,
    multiple,
    selectedReferences,
    srcRef,
    srcId,
    req,
  } = props

  const isCancelled = React.useRef(false);

  const [items, setItems] = useState([])
  const [fields, setFields] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchPlaceholder, setSearchPlaceholder] = useState('')
  const [selectPlaceholder, setSelectPlaceholder] = useState('')
  const [loadingMessage, setLoadingMessage] = useState('')
  const [filterPlaceholder, setFilterPlaceholder] = useState('')

  function fetch() {
    let config = {
      retry: 3,
      retryDelay: 1000,
    };
    // Retry failed requests
    axios.interceptors.response.use(undefined, (err) => {
      let config = err.config;
      if (!config || !config.retry) return Promise.reject(err);
      config.__retryCount = config.__retryCount || 0;
      if (config.__retryCount >= config.retry) {
        return Promise.reject(err);
      }
      config.__retryCount += 1;
      let backoff = new Promise(function (resolve) {
        setTimeout(function () {
          resolve();
        }, config.retryDelay || 1);
      });
      return backoff.then(function () {
        return axios(config);
      });
    });

    axios.get(`/react/${catalog}/${locale}/${itemType}?page=1`, config).then(res => {
      if (!isCancelled.current) {
        setSearchPlaceholder(res.data.search_placeholder)
        setSelectPlaceholder(res.data.select_placeholder)
        setFilterPlaceholder(res.data.filter_placeholder)
        setLoadingMessage(res.data.loading_message)
        setItems(res.data.items)
        setFields(res.data.fields)
        setIsLoading(false)
      }
      return null;
    })
  }
  useLayoutEffect(() => {
    fetch()

    return () => {
      isCancelled.current = true;
    };
  }, [])

  function _getNoOptionsMessage() {
    return () => noOptionsMessage;
  }

  function renderEditor() {
    if (isLoading) return null;
    if (multiple)
      return <MultiReferenceEditor
        items={items}
        itemsUrl={`/react/${catalog}/${locale}/${itemType}`}
        fields={fields}
        searchPlaceholder={searchPlaceholder}
        filterPlaceholder={filterPlaceholder}
        selectedReferences={selectedReferences}
        srcRef={srcRef}
        srcId={srcId}
        req={req}
        noOptionsMessage={_getNoOptionsMessage()}
      />
    else
      return <SingleReferenceEditor
        items={items}
        itemsUrl={`/react/${catalog}/${locale}/${itemType}`}
        fields={fields}
        searchPlaceholder={selectPlaceholder}
        filterPlaceholder={filterPlaceholder}
        selectedReference={selectedReferences}
        loadingMessage={loadingMessage}
        srcRef={srcRef}
        srcId={srcId}
        req={req}
        noOptionsMessage={_getNoOptionsMessage()}
      />
  }

  return (
    <div id={this?.editorId ? this.editorId : 'id'} className="referenceEditor">
      {isLoading && <div className="loader"></div>}
      {renderEditor()}
    </div>
  );
}

export default ReferenceEditor;
