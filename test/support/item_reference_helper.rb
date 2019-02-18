module ItemReferenceHelper
  def add_single_reference(id, name)
    find(:css, id).click
    page.execute_script(
      "Array.from(document.querySelectorAll(" \
        "'#{id} div'" \
      ")).find(el => el.textContent === '#{name}').click();"
    )
    find("body").click
  end

  def add_multiple_reference(id, name)
    page.execute_script(
      "Array.from(document.querySelectorAll(" \
        "'#{id} div.availableReferences div'" \
      ")).find(el => el.textContent === '#{name}').click();"
    )
  end
end
