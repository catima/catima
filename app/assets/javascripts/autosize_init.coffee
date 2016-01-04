init = ->
  autosize($("textarea:not([data-provider=summernote])"))

$(document).ready(init)
