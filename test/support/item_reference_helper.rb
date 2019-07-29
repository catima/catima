module ItemReferenceHelper
  def add_single_reference(id, name)
    find(:css, id, :wait => 30).click
    assert(page.has_css?("#{id} div[role=\"option\"]"), :wait => 30)
    page.execute_script(
      "Array.from(document.querySelectorAll(" \
        "'#{id} div'" \
      ")).find(el => el.textContent === '#{name}').click();"
    )
    find("body").click
  end

  def add_multiple_reference(id, name)
    assert(page.has_css?("#{id} div.item"), :wait => 30)
    page.execute_script(
      "Array.from(document.querySelectorAll(" \
        "'#{id} div.availableReferences div'" \
      ")).find(el => el.textContent === '#{name}').click();"
    )
  end
end
