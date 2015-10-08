init = ->
  system_admin_box = $("#user_system_admin")
  cat_boxes = $("input[type=checkbox][name='user[catalog_ids][]']")
  edit_permissions = $("[data-edit-permissions]")

  update_boxes = (evt)->
    if system_admin_box.get(0).checked
      cat_boxes.prop("checked", true)
      cat_boxes.attr("disabled", true)
      edit_permissions.hide()
    else
      cat_boxes.attr("disabled", false)
      edit_permissions.show()

  if system_admin_box.length > 0
    system_admin_box.on "change", update_boxes
    update_boxes()

$(document).ready(init)
