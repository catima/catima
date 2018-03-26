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
  $form.find("[data-field-category=#{category}]").closest(".form-component").show()

hide_all_category_fields = ($form)->
  $form.find("[data-field-category]").parent(".form-group").hide()
  $form.find("[data-field-category]").closest(".form-component").hide()

init_multivalued_selects = ->
  $("select[data-select2-tagging]").select2(theme: "bootstrap")


init_file_upload_controls = ->
  # Get all file input controls (one for each field)
  $upload_controls = $('div.file-upload')
  return if $upload_controls.length == 0
  # Init each individual field
  init_file_upload_field $(ctrl).attr('data-field') for ctrl in $upload_controls

init_file_upload_field = ($file_field)->
  $files = files_for $file_field
  $control = $("#fileupload_#{$file_field}")
  display_existing_files($file_field, $files, $control)
  activate_delete_file_buttons_for($file_field)
  activate_legend_image_input_for $file_field
  add_legends_for $file_field
  add_upload_button_for $file_field
  activate_jquery_fileupload $file_field
  check_filerequired $file_field

nfiles = ($field)->
  n = files_for($field).length
  # Check also if there are any files being uploaded, and add them as they are not yet in storage
  $control = $("#fileupload_#{$field}")
  n += $control.find('.upload-progress').length
  return n

multiple = ($file_field)->
  return ($("#fileupload_#{$file_field}").attr('data-multiple') == 'true')

legend = ($file_field)->
  return ($("#fileupload_#{$file_field}").attr('data-legend') == 'true')

required = ($field)->
  return ($("#fileupload_#{$field}").attr('data-required') == 'true')

upload_url = ($file_field)->
  return $("#fileupload_#{$file_field}").attr('data-upload-url')

allowed_extensions = ($field)->
  exts = $("#fileupload_#{$field}").attr('data-file-types').split(',')
  return (ext.trim().toLowerCase() for ext in exts)

auth_token = ->
  $('input[name=authenticity_token]').val()

display_existing_files = ($file_field, $files, $control)->
  h = (file_presenter $file_field, file for file in $files).join('')
  $control.append("<table>"+h+"</table>")

file_presenter = ($file_field, $file, $new=false, $uploading=false)->
  return if $uploading then file_presenter_upload_inprogress($file) else file_presenter_upload_finished($file_field, $file)

file_presenter_upload_finished = ($file_field, $file)->
  $is_img = ($file.type.substr(0,5) == 'image')
  $file_icon = if $is_img then "#{icon_for($file, 50)}" else '<i class="fa fa-file"></i>'
  $html = """
    <tr data-file="#{file_hash($file)}">
      <td>#{$file_icon}</td>
      <td><a href="/#{$file.path}">#{$file.name}</a></td>
      <td>#{format_file_size($file.size,1)}</td>
      <td>
        <button type="button" class="delete-file-btn btn btn-sm btn-danger"><span class="glyphicon glyphicon-trash"></span></button>
      </td>
    </tr>
    """
  if legend $file_field
    $html += """
    <tr data-file="#{file_hash($file)}">
      <td colspan="4">
        <input class="form-control image-legend-input" placeholder="Add legend here" type="text"/>
      </td>
    </tr>"""
  return $html

file_presenter_upload_inprogress = ($file)->
  return """
    <tr data-file="#{file_hash($file)}">
      <td><img src="/icons/file-upload.png" width="32" height="32" /></td>
      <td>#{$file.name}</td>
      <td>#{format_file_size($file.size,1)}</td>
      <td><span class="upload-progress">0%</span></td>
      </td>
    </tr>"""

icon_for = ($file, $size)->
  return "" if typeof($file.path) == 'undefined' or $file.path == ''
  return """<img src="#{thumbnail_path($file.path, $size)}" />"""

thumbnail_path = ($img_path, $size)->
  p = $img_path.split('/')
  return "/thumbs/#{p[1]}/#{$size}x#{$size}/fill/#{p[2]}/#{p[3]}"

# Calculates a base64 value with the file name and size, used as a file id
file_hash = ($file)->
  file_id = "#{$file.name}_#{$file.size}"
  return (if typeof(btoa) == 'function' then btoa(unescape(encodeURIComponent(file_id))) else file_id)

format_file_size = (bytes, decimals)->
  return '0 Bytes' if bytes == 0
  k = 1024
  dm = decimals || 2
  sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
  i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];

add_upload_button_for = ($file_field)->
  button_lbl = $("#fileupload_#{$file_field}").attr('data-button-text')
  $("#fileupload_#{$file_field}").append("""
    <span class="btn btn-sm btn-success fileinput-button hidden">
      <i class="glyphicon glyphicon-plus"></i>
      <span>#{button_lbl}</span>
      <input id="fileinput_#{$file_field}" type="file" name="files[]" data-url="#{upload_url($file_field)}">
    </span>
  """)
  # Check if we should hide the button or not
  display_upload_button($file_field)

activate_jquery_fileupload = ($file_field)->
  $("#fileinput_#{$file_field}").fileupload({
    dataType: 'json',
    dropZone: null,
    formData: { authenticity_token: auth_token(), field: $file_field },
    add: (e, data)-> fileupload_add_for($file_field, data),
    done: (e, data)-> fileupload_done_for($file_field, data.result),
    error: (err)-> fileupload_error_for($file_field, err),
    progress: (e, data)-> fileupload_progress($file_field, data),
    progressall: (e, data)-> fileupload_progressall(data)
  })

# Keep track of the file fields we have modified so far.
window.modified_file_fields = [];

check_thumbnail_button_display = ($file_field)->
  shown = 1
  ctrl = $("##{$file_field}_thumbnail_control")
  if nfiles($file_field) == 0 or $.inArray($file_field, modified_file_fields) >= 0
    ctrl.addClass('hidden')
    shown = 0
  else
    ctrl.removeClass('hidden')
    shown = 1

# Check if we should display or not the upload button
display_upload_button = ($file_field)->
  m = multiple($file_field)
  if nfiles($file_field) == 0 or m
    $("#fileupload_#{$file_field} .fileinput-button").removeClass('hidden')
  else
    $("#fileupload_#{$file_field} .fileinput-button").addClass('hidden')
  check_thumbnail_button_display($file_field)

fileupload_add_for = ($field, $data)->
  # Validate if file is acceptable for field. If yes, submit.
  f = $data.files[0]
  if file_valid_for($field, f)
    $data.submit()
    insert_new_file(f, $field)
    display_upload_button($field)
  else
    fileupload_error($field, "The file '#{$data.files[0].name}' is not valid for this field.")
  check_filerequired($field)

file_valid_for = ($field, $file)->
  ext = extension_for($file.name)
  return false if typeof(ext) == 'undefined'
  allowed_exts = allowed_extensions($field)
  if allowed_exts.length == 0 or allowed_exts.indexOf(ext.toLowerCase()) > -1
    return true
  else
    return false

extension_for = ($filename)->
  return /(?:\.([^.]+))?$/.exec($filename)[1]

fileupload_done_for = ($field, $result)->
  modified_file_fields.push($field)
  control = $("#fileupload_#{$field}")
  file_id = file_hash($result.processed_file)
  new_presenter = file_presenter_upload_finished($field, $result.processed_file)
  control.find("tr[data-file='#{file_id}']").replaceWith(new_presenter)
  activate_delete_file_buttons_for $field
  activate_legend_image_input_for $field
  add_file_to_field($result.processed_file, $field)

fileupload_error_for = ($field, $err)->
  console.log('fileupload error', $err)

fileupload_progress = ($file_field, data)->
  progress = data.progress()
  prop = progress.loaded / progress.total
  show_progress(data.files[0], prop)

fileupload_progressall = (data)->
  console.log('progressall', data)

show_progress = ($file, $prop)->
  file_id = file_hash($file)
  $file_display = $("tr[data-file='#{file_id}']")
  $file_display.find('.upload-progress').html("#{parseInt($prop*100)}%")

insert_new_file = ($file, $field_id)->
  h = file_presenter($field_id, $file, true, true)
  $control = $("#fileupload_#{$field_id}")
  window.H = h
  window.C = $control
  $control.children('table').append(h)

add_file_to_field = ($file, $field)->
  f = files_for($field)
  f.push($file)
  save_files(f, $field)

files_for = ($field)->
  content = $("textarea#item_#{$field}_json").html()
  return [] if content == ""
  files = JSON.parse(content)
  if $.isArray(files)
    return files
  else
    return [files,]

save_files = ($files, $field)->
  if $files.length == 0
    $("textarea#item_#{$field}_json").html('')
    return
  $files = if multiple($field) then $files else $files[0]
  $("textarea#item_#{$field}_json").html(JSON.stringify($files))

upload_in_progress_for = ($field)->
  $control = $("#fileupload_#{$field}")
  return ($control.find('.upload-progress').length > 0)

activate_delete_file_buttons_for = ($field)->
  $control = $("#fileupload_#{$field}")
  $control.find('.delete-file-btn').on('click', (e)-> delete_file($field, e.target))

activate_legend_image_input_for = ($field)->
  $control = $("#fileupload_#{$field}")
  $control.find('.image-legend-input').on('input', (e)-> update_legend($field, e.target))

update_legend = ($field, $target)->
  file_id = $($target).closest('tr').attr('data-file')
  files = files_for($field)
  $.each files, (index, file) ->
    if file_hash(file) == file_id
      file.legend = $target.value
  save_files(files, $field)

add_legends_for = ($field)->
  files = files_for($field)
  $.each files, (index, file) ->
    if file.legend
      file_id = file_hash(file)
      $("tr[data-file='#{file_id}'] .image-legend-input").val file.legend

delete_file = ($field, $target)->
  modified_file_fields.push($field)
  file_id = $($target).closest('tr').attr('data-file')
  files = files_for($field)
  files_to_keep = []
  for f in files
    files_to_keep.push(f) if file_hash(f) != file_id
  save_files(files_to_keep, $field)
  $("tr[data-file='#{file_id}']").remove()
  display_upload_button($field)
  check_filerequired($field)

fileupload_error = ($field, $msg)->
  $control = $("#fileupload_#{$field}")
  msg_box = """<div id="#{$field}_alert" class="alert alert-danger" role="alert">#{$msg}</div>"""
  $control.prepend(msg_box)
  run = () -> dismiss_error($field)
  setTimeout(run, 3000)

dismiss_error = ($field)->
  $('#'+$field+'_alert').remove()

check_filerequired = ($field)->
  $control = $("#fileupload_#{$field}")
  n = nfiles($field)
  req = required($field)
  if req and n == 0
    msg_box = """
      <div id="#{$field}_required_alert" class="alert alert-warning" role="alert">
        A file is required for this field
      </div>"""
    $control.prepend(msg_box)
  else
    $('#'+$field+'_required_alert').remove()


$(document).ready(init_category_triggers)
$(document).ready(init_multivalued_selects)
$(document).ready(init_file_upload_controls)
