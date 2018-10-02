setCatalogAccess = (visible, restricted) ->
  document.getElementById('catalog_visible').value = visible == true
  document.getElementById('catalog_restricted').value = restricted == true
  return
init_access_callbacks = ->
  cat_access = document.getElementById('catalog_access')
  if cat_access
    cat_access.onchange = ->
      switch cat_access.value
        when '1'
          setCatalogAccess true, false
        when '2'
          setCatalogAccess true, true
        when '3'
          setCatalogAccess false, true
      return
$(document).ready(init_access_callbacks)
