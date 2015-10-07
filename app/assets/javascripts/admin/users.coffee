init = ->
  system_admin_box = $("#new_user #user_system_admin")
  cat_boxes = $("#new_user input[type=checkbox][name='user[catalog_ids][]']")

  update_boxes = (evt)->
    if system_admin_box.get(0).checked
      cat_boxes.prop("checked", true)
      cat_boxes.attr("disabled", true)
    else
      cat_boxes.attr("disabled", false)

  if system_admin_box.length > 0
    system_admin_box.on "change", update_boxes
    update_boxes()

$(document).ready(init)
