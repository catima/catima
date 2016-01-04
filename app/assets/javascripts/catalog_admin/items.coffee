init_category_triggers = ->
  $form = $("form.edit_item, form.new_item")
  hide_all_category_fields($form)
  $choice_sets = $form.find("[data-choice-category]").parent("select")
  $choice_sets.each ->
    show_selected_category_fields($form, $(this))
  $choice_sets.on "change", (evt)->
    hide_all_category_fields($form)
    show_selected_category_fields($form, $(this))

show_selected_category_fields = ($form, $choice_set)->
  $choice = $choice_set.find("option:selected")
  category = $choice.data("choice-category")
  $form.find("[data-field-category=#{category}]").parent(".form-group").show()

hide_all_category_fields = ($form)->
  $form.find("[data-field-category]").parent(".form-group").hide()

init_multivalued_selects = ->
  $("select[data-select2-tagging]").select2(theme: "bootstrap")

$(document).ready(init_category_triggers)
$(document).ready(init_multivalued_selects)
