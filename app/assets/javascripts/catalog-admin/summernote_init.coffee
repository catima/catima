init = ->
  $("[data-provider='summernote']").summernote
    height: 300
    maximumImageFileSize: 262144 # 256KB
    toolbar: [
      ['style', ['style']],
      ['font', ['bold', 'italic', 'underline', 'clear']],
      ['fontname', ['fontname']],
      ['color', ['color']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['table', ['table']],
      ['insert', ['link', 'picture', 'video']],
      ['view', ['fullscreen', 'codeview', 'help']],
    ]

$(document).ready(init)
