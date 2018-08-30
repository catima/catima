# --- Modal form for creating a new choice in data entry form ---

init_new_choice_modal_form = ->
  $('form.new_choice').on('ajax:success', (e, data, status, xhr) ->
    $(e.target).closest('div.modal').modal('hide')
    lang = $(e.target).closest('div.modal').attr('data-lang')

    option = new Option(data.choice.short_name_translations['short_name_'+lang], data.choice.id, false, true)
    $("[data-choice-set=#{data.choice_set}] select").append(option).trigger('change')
  ).on('ajax:error', (e, xhr) ->
    alert('Could not create new choice: ' + xhr.responseJSON.errors)
  )

$(document).ready(init_new_choice_modal_form)


# --- Modal form for creating a new choice set in new field form ---

init_new_choice_set_modal_form = ->
  $('#new-choice-set-modal form').on('ajax:success', (e, data, status, xhr) ->
    $(e.target).closest('div.modal').modal('hide')

    $("select#field_choice_set_id").append("<option value=\"#{data.choice_set.id}\">#{data.choice_set.name}</option>")

    $("select#field_choice_set_id").val(data.choice_set.id)

  ).on('ajax:error', (e, xhr) ->
    alert('Could not create new choice set: ' + xhr.responseJSON.errors)
  )

$(document).ready(init_new_choice_set_modal_form)
