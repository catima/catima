init = ->
  # Changes the search fields based on the selected item type
  $('#advanced_search_configuration_item_type').on "change", (e) ->
    hasMap = $(this).find("option:selected").data("has-map") == true
    $("#advanced_search_configuration_search_type").prop("disabled", !hasMap)
    $("#advanced_search_configuration_search_type").parent().toggle(hasMap)
    
  $('#advanced_search_configuration_item_type').trigger("change")

$(document).ready(init)
