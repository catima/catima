$(document).ready ->
  $('[data-toggle="tooltip"]').tooltip()

  popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  popoverList = popoverTriggerList.map (popoverTriggerEl) =>
    new bootstrap.Popover(popoverTriggerEl, {html: true})
