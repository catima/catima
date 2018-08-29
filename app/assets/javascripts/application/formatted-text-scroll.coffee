check_formatted_text_height = ->
  $('div.formatted-text').each ->
    if $(this).height() == 500
      $(this).css('overflow-y', 'scroll')

$(document).ready(check_formatted_text_height)