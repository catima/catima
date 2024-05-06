module DatepickerHelper
  def select_day(input_day_id, day)
    find(:css, input_day_id).click
    page.execute_script(
      "document.querySelector(\".tempus-dominus-widget [data-day='#{day}']\").click();"
    )
  end
end
