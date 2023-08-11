import React, {useEffect, useRef, useState, forwardRef} from 'react';
import Translations from '../../Translations/components/Translations';
import PropTypes from "prop-types";
import axios from 'axios';
import ReactSelect from 'react-select';

const ASCENDING = 'ASC';
const DESCENDING = 'DESC';
const sortAlphabeticaly = (direction, isNum) => {
  return (a, b) => {
    if (a === ' ' || a === '') {
      return 1
    }
    if (b === ' ' || b === '') {
      return -1
    }
    a = isNum ? parseInt(a) : a
    b = isNum ? parseInt(b) : b
    if (a > b) {
      return direction === ASCENDING ? 1 : -1
    }
    if (a < b) {
      return direction === ASCENDING ? -1 : 1
    }
    return 0
  }
}

const computeGroupTitle = (level, title, type) => {
  if (level === 1 && type === 'date') {
    return Translations.messages[`catalog_admin.fields.date_time_option_inputs.months.${['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'][parseInt(title - 1)]}`]
  }

  return title
}

const Items = forwardRef((props, ref) => {
  const {items} = props

  const renderItem = (item, index) => {
    return (
      <div
        className={((ref.current % 2) === 0) ? 'line__group__item__wrapper  odd' : 'line__group__item__wrapper  even'}
        key={`${item.id}-${index}`}>
        <div className="line__group__item text-component">
          <div dangerouslySetInnerHTML={{__html: item.title}}/>
          <p className="color-contrast-medium" dangerouslySetInnerHTML={{__html: item.summary}}/>
        </div>
      </div>
    )
  }

  const renderItems = (items) => {
    return (
      <div className="line__group__items__wrapper">
        {items.map((it, idx) => {
            ref.current += 1
            return renderItem(it, idx)
          }
        )}
      </div>
    )
  }

  return renderItems(items)
})

const ItemGroup = forwardRef((props, ref) => {
  const {items, icons, k, title, level, type, withoutGroup, sort} = props

  const recursiveRenderItems = (items, key, title, level) => {
    let it = {...items}

    if (typeof items === 'object' && !Array.isArray(items)) {
      return (
        <div className="line__group" key={`${key}`} data-controller="toggle-display-line">
          {!(type === 'num' && level === 1) && !withoutGroup && (
            <div className={`line__group__title level-${level}`} style={{cursor: "pointer"}} data-action="click->toggle-display-line#reveal">
              <div dangerouslySetInnerHTML={{__html: computeGroupTitle(level, title, type)}}/>
              <span className="px-2" data-toggle-display-line-target="upArrow"
                    dangerouslySetInnerHTML={{__html: icons.up}}/>
              <span className="px-2 d-none" data-toggle-display-line-target="downArrow"
                    dangerouslySetInnerHTML={{__html: icons.down}}/>
            </div>
          )}
          <div className={`line__group__items ${(withoutGroup || !!(type === 'num' && level === 1)) ? '' : 'd-none'}`}
               data-toggle-display-line-target={`${!(type === 'num' && level === 1) && !withoutGroup ? "revealable" : ""}`}>
            {(it.hasOwnProperty(' ') && (<ItemGroup icons={icons} key={`no`} k={`no`} title={'no'} items={it[' ']}
                                                    level={level + 1} sort={sort}
                                                    type={type} withoutGroup={true} ref={ref}/>))}
            {(it.hasOwnProperty(' ') && (
                (() => {
                  delete it[' ']
                  Object.keys(it).sort(sortAlphabeticaly(sort, type === 'num')).map((k, idx) => {
                    return <ItemGroup icons={icons} key={`${key}-${idx}`} k={`${key}-${idx}`} title={k} items={it[k]}
                                      level={level + 1} type={type} sort={sort}
                                      withoutGroup={false} ref={ref}/>
                  })
                })()
              )
              || (
                Object.keys(it).sort(sortAlphabeticaly(sort, type === 'num')).map((k, idx) => {
                  return <ItemGroup icons={icons} key={`${key}-${idx}`} k={`${key}-${idx}`} title={k} items={it[k]}
                                    level={level + 1} type={type} sort={sort} ref={ref}/>
                })
              ))}
          < /div>
        </div>
      )
    } else {
      return (
        <div className="line__group" key={`${key}`} data-controller="toggle-display-line">
          {!(type === 'num' && level === 1) && !withoutGroup && (
            <div className={`line__group__title level-${level}`} style={{cursor: "pointer"}} data-action="click->toggle-display-line#reveal">
              <div dangerouslySetInnerHTML={{__html: computeGroupTitle(level, title, type)}}/>
              <span className="px-2" data-toggle-display-line-target="upArrow"
                    dangerouslySetInnerHTML={{__html: icons.up}}/>
              <span className="px-2 d-none" data-toggle-display-line-target="downArrow"
                    dangerouslySetInnerHTML={{__html: icons.down}}/>
            </div>)}
          <div className={`${(withoutGroup || !!(type === 'num' && level === 1)) ? '' : 'd-none'}`} style={{width: '100%'}} data-toggle-display-line-target={`${!(type === 'num' && level === 1) && !withoutGroup ? "revealable" : ""}`}>
            <Items items={items} ref={ref}/>
          </div>
        </div>
      )
    }
  }

  return (
    recursiveRenderItems(items, k, title, level)
  )
})

const Line = (props) => {
  const {
    sort,
    url,
    links,
    icons,
    currentPage: currentPageProps,
    pageCount,
    type
  } = props

  const [isFetching, setIsFetching] = useState(false)
  const [groupedItems, setGroupedItems] = useState({})
  const [currentPage, setCurrentPage] = useState(parseInt(currentPageProps))
  const currentCount = useRef(0)

  useEffect(() => {
    setCurrentPage(parseInt(currentPageProps))
  }, [currentPageProps])

  useEffect(() => {
    axios.defaults.headers.common["X-CSRF-Token"] = (document.querySelector("meta[name=csrf-token]") || {}).content;
    axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    fetchItems(currentPage)
  }, [])

  function recursiveDeepMerge(newGroupedItems, newItems) {
    Object.entries(newItems).forEach(([key, val]) => {
      if (newGroupedItems.hasOwnProperty(key)) {
        if (Array.isArray(newGroupedItems[key])) {
          newGroupedItems[key] = newGroupedItems[key].concat(val)
        } else {
          recursiveDeepMerge(newGroupedItems[key], val)
        }
      } else {
        newGroupedItems[key] = val
      }
    })
    return newGroupedItems
  }

  async function fetchItems(page) {
    setIsFetching(true)
    let {data: {items: newItems}} = await axios.get(url + `&page=${page}`)
    setCurrentPage(page)

    let newGroupedItems = {...groupedItems}

    setGroupedItems({...await recursiveDeepMerge(newGroupedItems, newItems)})
    setIsFetching(false)
  }

  const sortAscDesc = (e) => {
    if (e.value === ASCENDING) {
      window.location.assign(links.asc)
    } else if (e.value === DESCENDING) {
      window.location.assign(links.desc)
    }
  }

  const loader = <div className="d-flex justify-content-center align-items-center">
    <div className="loader"/>
  </div>
  if (!Object.keys(groupedItems).length) return loader

  return (
    <div data-controller="toggle-display-line">
      <div className='w-25'
           style={{marginLeft: '50%', transform: 'translate(-50%, 0)', position: "relative", zIndex: "2"}}>
        <ReactSelect
          id='asc-desc'
          name='asc-desc'
          options={[
            {value: ASCENDING, label: Translations.messages['containers.item_list.asc']},
            {value: DESCENDING, label: Translations.messages['containers.item_list.desc']}
          ]}
          onChange={sortAscDesc}
          placeholder={Translations.messages['containers.item_list.select_sort']}
          value={[
            {value: ASCENDING, label: Translations.messages['containers.item_list.asc']},
            {value: DESCENDING, label: Translations.messages['containers.item_list.desc']}
          ].filter(o => o.value === sort)}
        />
      </div>
      <div className='d-flex justify-content-center'>
        <a className="m-2" href="#" data-action="click->toggle-display-line#hideAllElements">
          {Translations.messages['containers.item_list.close_all']}
        </a>
        <a className="m-2" href="#" data-action="click->toggle-display-line#showAllElements">
          {Translations.messages['containers.item_list.open_all']}
        </a>
      </div>
      <section className="line">
        <div className="container max-width-lg line__container">
          {
            Object.keys(groupedItems)
              .sort(sortAlphabeticaly(sort, type === 'num'))
              .map(
                (k, index) =>
                  <ItemGroup key={k} k={k} title={k}
                             icons={icons}
                             items={groupedItems[k]}
                             level={0}
                             sort={sort}
                             type={type}
                             withoutGroup={false}
                             ref={currentCount}
                  />
              )
          }
        </div>
      </section>
      {currentPage !== pageCount && (
        <div className='d-flex justify-content-center'>
          {isFetching && (
            loader
          ) || (
            <button className="btn btn-lg btn-primary" onClick={() => fetchItems(currentPage + 1)}>
              {Translations.messages['containers.item_list.more']}
            </button>
          )}
        </div>
      )}
    </div>
  )
}

Line.propTypes = {
  url: PropTypes.string.isRequired,
}

export default Line;
