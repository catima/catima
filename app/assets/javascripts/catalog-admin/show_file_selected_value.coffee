init_show_file_value = ->
  $('.custom-file-input').on("change", (e) ->
    $('.custom-file-label').text(this.value.substr(Math.max(this.value.lastIndexOf("/"), this.value.lastIndexOf("\\"))+1))
  )

$(document).ready(init_show_file_value)
