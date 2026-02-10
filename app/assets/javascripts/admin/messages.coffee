init_message_catalog_select = ->
  # Only target the catalog select in the message form
  $catalog_select = $("#message_catalog_id[data-select2-tagging]")
  return unless $catalog_select.length > 0

  # Only initialize if not already initialized
  unless $catalog_select.hasClass('select2-hidden-accessible')
    $catalog_select.select2
      theme: "bootstrap"
      minimumResultsForSearch: 0  # Always show search box
      placeholder: $catalog_select.data('placeholder') || 'All catalogs (global message)'
      allowClear: true

$(document).ready(init_message_catalog_select)
$(document).on('turbolinks:load', init_message_catalog_select)
