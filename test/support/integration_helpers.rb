require_relative "./customized_files"

class ActionDispatch::IntegrationTest
  include CustomizedFiles

  private

  def fill_in_hidden(id, with:)
    find("##{id}", :visible => :all).set(with)
  end

  def log_in_as(email, password)
    visit("/en/login")
    fill_in("Email", :with => email)
    fill_in("Password", :with => password)
    within("form") { click_on("Log in") }
  end

  def logout
    find('#user-menu').click
    click_on('Log out')
  end
end
