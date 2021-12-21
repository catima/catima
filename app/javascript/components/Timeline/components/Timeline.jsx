import React, {useState, useEffect, useRef} from 'react';
import PropTypes from "prop-types";
import axios from 'axios';
import "../css/timeline.scss";
import ReactSelect from 'react-select';

const Timeline = (props) => {
  const {
    sort_direction,
    url,
    links,
    icons,
    currentPage: currentPageProps,
    pageCount
  } = props

  const [isFetching, setIsFetching] = useState(false)
  const [groupedItems, setGroupedItems] = useState({})
  const [groupIsOpen, setGroupIsOpen] = useState([])
  const [allOpen, setAllOpen] = useState(true)
  const [currentPage, setCurrentPage] = useState(parseInt(currentPageProps))

  const moreBtnRef = useRef(false)


  useEffect(() => {
    setCurrentPage(parseInt(currentPageProps))
  }, [currentPageProps])

  useEffect(() => {
    const csrfToken = (document.querySelector("meta[name=csrf-token]") || {}).content;
    axios.defaults.headers.common["X-CSRF-Token"] = csrfToken;
    axios.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
    fetchItems(currentPage)
  }, [])

  useEffect(() => {
    if (Object.keys(groupedItems).length === groupIsOpen.length) return
    setGroupIsOpen(groupIsOpen.concat(Array.from({length: Object.keys(groupedItems).length - groupIsOpen.length}, (_, i) => allOpen)))
  }, [groupedItems])

  const toggleGroupIsOpen = (idx) => {
    let g = groupIsOpen
    g[idx] = !g[idx]
    setGroupIsOpen([...g])
  }

  const toggleAllGroupAreOpen = (state) => {
    setAllOpen(state)
    setGroupIsOpen([...new Array(100).fill(state)])
  }

  async function fetchItems(page) {
    setIsFetching(true)
    let {data: {items: newItems}} = await axios.get(url + `&page=${page}`)
    setCurrentPage(page)
    let newGroupedItems = groupedItems
    Object.entries(newItems).forEach(([k, v]) => {
      if (groupedItems.hasOwnProperty(k)) {
        newGroupedItems[k] = newGroupedItems[k].concat(v)
      } else {
        newGroupedItems[k] = v
      }
    })
    setGroupedItems({...newGroupedItems})
    setIsFetching(false)
  }

  let i = 0
  const renderItems = (items, key, groupIndex, isOpen) => {
    return (
      <div className="timeline__group" key={`group-${key}`}>
        <div className="timeline__group__title">
          <div dangerouslySetInnerHTML={{__html: items[0].group_title}}></div>
          <span className="px-2"  style={{cursor: "pointer"}} onClick={() => toggleGroupIsOpen(groupIndex)}
                dangerouslySetInnerHTML={{__html: groupIsOpen[groupIndex] ? icons.up : icons.down}}></span>
        </div>

        {groupIsOpen[groupIndex] && (
          <div className="timeline__group__items">
            {items.map((item, idx) => (
                <div
                  className={(((i += 1) % 2) == 0) ? 'timeline__group__item__wrapper  odd' : 'timeline__group__item__wrapper  even'}
                  key={`${item.id}-${idx}`}>
                  <div className="timeline__group__item text-component">
                    <div dangerouslySetInnerHTML={{__html: item.title}}></div>
                    <p className="color-contrast-medium" dangerouslySetInnerHTML={{__html: item.summary}}></p>
                  </div>
                </div>
              )
            )}
          </div>
        )}
      </div>
    )
  }

  const sortAscDesc = (e) => {
    console.log(e)
    if (e.value == 'ASC') {
      window.location.assign(links.asc)
    } else if (e.value == 'DESC') {
      window.location.assign(links.desc)
    }
  }
  const loader = <div className="d-flex justify-content-center align-items-center"><div className="loader"></div></div>
  if (!Object.keys(groupedItems).length) return  loader

  return (
    <div>
       <div className='w-25' style={{marginLeft: '50%', transform: 'translate(-50%, 0)'}}>
        <ReactSelect
          id='asc-desc'
          name='asc-desc'
          options={[{value: 'ASC', label: 'Ascending'}, {value: 'DESC', label: 'Descending'}]}
          onChange={sortAscDesc}
          placeholder='Select Sort Order'
          value={[{value: 'ASC', label: 'Ascending'}, {
            value: 'DESC',
            label: 'Descending'
          }].filter(o => o.value === sort_direction)}

        />
      </div>
      <div className='d-flex justify-content-center'>
        {allOpen && (
          <a className="m-2" href="#" onClick={() => toggleAllGroupAreOpen(false)}>Close All</a>
        ) || (<a className="m-4" href="#" onClick={() => toggleAllGroupAreOpen(true)}>Open All</a>)}
      </div>

      <section className="timeline">
        <div className="container max-width-lg timeline__container">
          {Object.entries(groupedItems).map(([k, v], index) => renderItems(v, k, index, groupIsOpen[index]))}
        </div>
      </section>
      {currentPage !== pageCount && (
        <div className='d-flex justify-content-center'>
          {isFetching && (
            loader
          ) || (
            <button className="btn btn-lg btn-primary" onClick={() => fetchItems(currentPage + 1)}>More</button>
          )}
        </div>
      )}
    </div>
  )
}

Timeline.propTypes = {
  url: PropTypes.string.isRequired,
}

export default Timeline;
