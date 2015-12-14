init = ->
  $mode_select = $("#configuration_root_mode")
  $redirect_select = $("#configuration_default_catalog_id")

  show_hide_select = (evt)->
    root_mode = $mode_select.val()
    $redirect_select.toggle(root_mode == "redirect")

  show_hide_select()
  $mode_select.on("change", show_hide_select)

$(document).ready(init)
