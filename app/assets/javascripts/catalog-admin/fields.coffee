init = ->
  $('#field_formatted_text').on 'change', (e) ->
    if $('#field_primary').length
      if $('#field_formatted_text')[0].checked
        $('#field_primary').attr 'disabled', 'disabled'
        $('.checkbox:has(#field_primary)').addClass("disabled")
      else
        $('#field_primary').attr 'disabled', null
        $('.checkbox:has(#field_primary)').removeClass("disabled")
      return

  $('#field_primary').on 'change', (e) ->
    if $('#field_formatted_text').length
      if $('#field_primary')[0].checked
        $('#field_formatted_text').attr 'disabled', 'disabled'
        $('.checkbox:has(#field_formatted_text)').addClass("disabled")
      else
        $('#field_formatted_text').attr 'disabled', null
        $('.checkbox:has(#field_formatted_text)').removeClass("disabled")
      return

  $('#field_auto_increment').on 'change', (e) ->
    if $('#field_default_value').length
      if $('#field_auto_increment')[0].checked
        $('#field_default_value').attr 'value', ''
        $('#field_default_value').attr 'disabled', 'disabled'
      else
        $('#field_default_value').attr 'disabled', null
      return

  if $('#field_auto_increment').length && $('#field_default_value').length
    if $('#field_auto_increment')[0].checked
      $('#field_default_value').attr 'disabled', 'disabled'

$(document).ready(init)
