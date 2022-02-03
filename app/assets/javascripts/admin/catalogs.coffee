init = ->
  primary_lang = $("#catalog_primary_language")
  other_lang_boxes = \
    $("input[type=checkbox][name='catalog[other_languages][]']")

  update_boxes = (evt)->
    primary_value = primary_lang.val()
    other_lang_boxes.attr("disabled", false)
    match_box = $("input[type=checkbox][value=#{primary_value}]")
    match_box.attr("disabled", true)

  if primary_lang.length > 0
    primary_lang.on "change", update_boxes
    update_boxes()

  $('#catalog_data_only').on 'change', (e) ->
    if $('#catalog_data_only')[0].checked
      $('#catalog_custom_root_page_id').attr 'disabled', 'disabled'
      $('#catalog_advertize').prop 'checked', false
      $('#catalog_advertize').attr 'disabled', 'disabled'
    else
      $('#catalog_custom_root_page_id').attr 'disabled', null
      $('#catalog_advertize').attr 'disabled', null
    return

$(document).ready(init)
