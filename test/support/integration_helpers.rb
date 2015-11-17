class ActionDispatch::IntegrationTest
  private

  def log_in_as(email, password)
    visit("/en/login")
    fill_in("Email", :with => email)
    fill_in("Password", :with => password)
    within("form") { click_on("Log in") }
  end

  def with_customized_file(source, dest)
    source = Rails.root.join(source)
    dest_bak = Rails.root.join("#{dest}.bak")
    dest = Rails.root.join(dest)

    FileUtils.mkdir_p(dest.dirname)
    FileUtils.mv(dest, dest_bak) if dest.file?
    FileUtils.cp(source, dest)
    yield
  ensure
    dest.unlink
    FileUtils.mv(dest_bak, dest) if dest_bak.file?
  end
end
