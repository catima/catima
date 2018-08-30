init = ->
  Mousetrap.reset()
  $("[data-add-another]").each (i, el) ->
    Mousetrap.bindGlobal "shift+enter", (e) ->
      el.click()
      e.returnValue = false

$(document).ready(init)
