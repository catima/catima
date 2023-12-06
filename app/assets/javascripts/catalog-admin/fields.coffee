is_checked = (field_id) ->
  $field = $("##{field_id}")
  $field.length && $field[0].checked

manage_states = ->
  # Enable or disable fields according to their "policies" (see fields_disabled_policies).
  for field_id, func_should_be_disabled of fields_disabled_policies
    $field = $("##{field_id}")
    if $field.length
      if func_should_be_disabled()
        $field.attr 'disabled', 'disabled'
        $(".checkbox:has(##{field_id})").addClass("disabled")
      else
        $field.attr 'disabled', null
        $(".checkbox:has(##{field_id})").removeClass("disabled")

# An object with field_id as key and a lambda returning if the associated field
# must be enabled or disabled as value.
fields_disabled_policies = {
  field_formatted_text: ->
    is_checked('field_primary')
  ,
  field_primary: ->
    is_checked('field_formatted_text') || is_checked('field_restricted')
  ,
  field_restricted: -> is_checked('field_primary'),
  field_default_value: -> is_checked('field_auto_increment')
}

init = ->
  manage_states()

  $('
    #field_formatted_text,
    #field_restricted,
    #field_primary,
    #field_display_in_public_list,
    #field_auto_increment
  ').on 'change', manage_states

$(document).ready(init)
