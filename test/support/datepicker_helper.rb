module DatepickerHelper
  def select_day(id, input_day_id, day)
    find(:css, input_day_id).click
    page.execute_script(
      "Array.from(document.querySelectorAll(" \
        "'#{id} td.day'" \
      ")).find(el => el.textContent === '#{day}').click();"
    )
  end
end
