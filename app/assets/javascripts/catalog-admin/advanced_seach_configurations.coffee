init_search_type = ->
  layers ($("#advanced_search_configuration_search_type :selected").val())

  $('#advanced_search_configuration_search_type').on "change", (e) ->
    layers (e.target.value)

layers = (value) ->
  layers_input = document.getElementById('searchLayers')
  if layers_input == null
    return
  layers_input.style.display = 'none'
  if value == 'map'
    layers_input.style.display = 'block'
  return

$(document).ready(init_search_type)
