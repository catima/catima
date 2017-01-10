init_modal_forms = ->
  $('form.new_choice').on('ajax:success', (e, data, status, xhr) ->
    $(e.target).closest('div.modal').modal('hide')

    lang = $(e.target).closest('div.modal').attr('data-lang')
    $("[data-choice-set=#{data.choice_set}] select").append("<option value=\"#{data.choice.id}\">#{data.choice.short_name_translations['short_name_'+lang]}</option>")

    field_uuid = $(e.target).closest('div.modal').attr('data-field-uuid')
    $('#item_'+field_uuid).val(data.choice.id)

  ).on('ajax:error', (e, xhr) ->
    alert('Could not create new choice: ' + xhr.responseJSON.errors)
  )

$(document).ready(init_modal_forms)