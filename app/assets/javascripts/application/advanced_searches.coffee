init = ->
  $("#new_advanced_search select[multiple]").select2(theme: "bootstrap")

  # Changes the id and the name of the search input field when changing the selected filter (exact, all_words, contains)
  $(".filter-condition").on "change", (e) ->
    changeInputName($(this))

  # When user clicks on reload page or previous page in the browser, sets the correct name on page load
  $(".filter-condition").each (index, select) ->
    changeInputName($(select))

changeInputName = (selectInput) ->
  selectedFilter = selectInput.val()
  templateField = selectInput.parents(".row").find(".template")

  filerFieldName = templateField.attr("name").replace(/__filter__/g, selectedFilter);
  filerFieldId = templateField.attr("id").replace(/__filter__/g, selectedFilter);

  selectInput.parents('.row').find("input.form-control").first().attr("name", filerFieldName)
  selectInput.parents('.row').find("input.form-control").first().attr("id", filerFieldId)

$(document).ready(init)
