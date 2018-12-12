init = ->
  # Changes the search fields based on the selected item type
  $('#advanced_search_configuration_item_type').on "change", (e) ->
    window.location.replace($(this).find("option:selected").data("url"))

$(document).ready(init)
