import React, {useState, useEffect} from 'react';
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

  const [groupedItems, setGroupedItems] = useState({})
  const [groupIsOpen, setGroupIsOpen] = useState([])
  const [allOpen, setAllOpen] = useState(true)
  const [currentPage, setCurrentPage] = useState(parseInt(currentPageProps))


  useEffect(() => {
    setCurrentPage(parseInt(currentPageProps))
  }, [currentPageProps])

  useEffect(() => {
    fetchItems(currentPage)
  }, [])

  useEffect(() => {
    if (Object.keys(groupedItems).length === groupIsOpen.length) return
    setGroupIsOpen(groupIsOpen.concat(Array.from({length: Object.keys(groupedItems).length - groupIsOpen.length}, (_, i) => allOpen)))
  }, [groupedItems])

  const toggleGroupIsOpen = (idx) => {
    console.log(idx)
    let g = groupIsOpen
    g[idx] = !g[idx]
    setGroupIsOpen([...g])
  }

  const toggleAllGroupAreOpen = (state) => {
    setAllOpen(state)
    setGroupIsOpen([...new Array(100).fill(state)])
  }

  async function fetchItems(page) {
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
  }

  let i = 0
  const renderItems = (items, key, groupIndex, isOpen) => {
    return (
      <div className="timeline__group" key={`group-${key}`}>
        <div className="timeline__group__title">
          <div dangerouslySetInnerHTML={{__html: items[0].group_title}}></div>
          <span className="px-2" onClick={() => toggleGroupIsOpen(groupIndex)}
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

  if (!groupedItems) return 'loading'

  const sortAscDesc = (e) => {
    console.log(e)
    if (e.value == 'ASC') {
      window.location.assign(links.asc)
    } else if (e.value == 'DESC') {
      window.location.assign(links.desc)
    }
  }

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
        <button className="btn btn-sm m-2 btn-primary" onClick={() => toggleAllGroupAreOpen(true)}>Open All</button>
        <button className="btn btn-sm m-2 btn-primary" onClick={() => toggleAllGroupAreOpen(false)}>Close All</button>
      </div>

      <section className="timeline">
        <div className="container max-width-lg timeline__container">
          {/*{renderItemGroups(groupedItems)}*/}
          {Object.entries(groupedItems).map(([k, v], index) => renderItems(v, k, index, groupIsOpen[index]))}
        </div>
      </section>
      {currentPage !== pageCount && (
        <div className='d-flex justify-content-center'>
          <button className="btn btn-lg btn-primary" onClick={() => fetchItems(currentPage + 1)}>More</button>
        </div>
      )}
    </div>
  )
}

Timeline.propTypes = {
  url: PropTypes.string.isRequired,
}

export default Timeline;
