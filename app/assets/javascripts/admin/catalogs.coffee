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

$(document).ready(init)
