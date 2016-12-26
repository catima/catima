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

$dropzones = []

init_dropzones = ->
  Dropzone.autoDiscover = false
  $dz_containers = $('div.dropzone')
  for $dz in $dz_containers
    $dropzones.push(build_dropzone($dz))
  $('item-form form').submit (e) ->
    if uploadsInProgress()
      e.preventDefault()
      return false

build_dropzone = ($dz) ->
  $field = $($dz).attr('data-field')
  $new_dz = new Dropzone('#'+$dz.id, {
    url: $('#item-form form').attr('action') + '/upload',
    autoProcessQueue: true,
    uploadMultiple: true,
    addRemoveLinks: true,
    parallelUploads: 10,
    fieldId: $field,
    maxFiles: if dz_multiple($dz) then null else 1,
    accept: ($file, $done) ->
      $accepted_files = $($dz).attr('data-file-types')
      if $accepted_files == ''
        $done()
        return
      for ext in $accepted_files.split(',')
        if $file.name.endsWith('.' + ext.trim())
          $done()
          return
      $done('This file type is not allowed for this field')
    ,
    params: {
      authenticity_token: $('input[name=authenticity_token]').val(),
      field: $dz.id
    },
    successmultiple: ($data, $response) ->
      console.log(['successmultiple', $data, $response])
      $fld = $response.field
      add_files_to_field($response.processed_files, $fld)

  })

  $new_dz.on 'removedfile', ($file) ->
    $field = this.options.fieldId
    remove_file_from_field($file, $field)

  dz_add_existing_files($new_dz, $field)
  return $new_dz


dz_multiple = ($dz) ->
  return ($($dz).attr('data-multiple') == 'true')

dz_add_existing_files = ($dz, $field) ->
  $files = get_files_for_field($field)
  for $file in $files
    $dz.emit 'addedfile', $file
    $dz.emit 'complete', $file
  if $dz.options.maxFiles
    $dz.options.maxFiles - $files.length

add_files_to_field = ($files, $field) ->
  $current_files = get_files_for_field($field)
  for $file in $files
    $current_files.push($file)
  set_files_for_field($current_files, $field)

remove_file_from_field = ($file, $field) ->
  $current_files = get_files_for_field($field)
  $files_to_keep = []
  for $f in $current_files
    if $f.name != $file.name || $f.size != $file.size
      $files_to_keep.push($f)
  console.log(['remove_file_from_field', $file, $field, $current_files, $files_to_keep])
  set_files_for_field($files_to_keep, $field)

get_files_for_field = ($field) ->
  try
    $val = JSON.parse($('#item_'+$field+'_json').html())
  catch
    $val = []
  $files = if $.isArray($val) then $val else [$val]
  return $files

set_files_for_field = ($files, $field) ->
  $files = if $.isArray($files) then $files else [$files]
  if $files.length == 0
    $('#item_'+$field+'_json').html('')
    return  
  $files = if dz_multiple('#dropzone_'+$field) then $files else $files[0]
  console.log(['set_files_for_field', $files, $field])
  $('#item_'+$field+'_json').html(JSON.stringify($files))


$(document).ready(init_category_triggers)
$(document).ready(init_multivalued_selects)
$(document).ready(init_dropzones)
