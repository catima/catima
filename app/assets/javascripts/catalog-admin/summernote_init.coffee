init = ->
  $("[data-provider='summernote']").summernote
    height: 300
    maximumImageFileSize: 262144 # 256KB

$(document).ready(init)
