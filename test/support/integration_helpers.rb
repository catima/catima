class ActionDispatch::IntegrationTest
  private

  def log_in_as(email, password)
    visit("/en/login")
    fill_in("Email", :with => email)
    fill_in("Password", :with => password)
    within("form") { click_on("Log in") }
  end
end
