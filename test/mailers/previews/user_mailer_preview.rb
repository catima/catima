# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Use meta-programming to define multiple methods for each locale
  %w(de en fr it).each do |locale|
    # Preview this email at
    # http://localhost:3000/rails/mailers/user_mailer/reset_password_instructions_en
    define_method("reset_password_instructions_#{locale}") do
      recipient = User.new(
        :email => "matt@mattbrictson.com",
        :primary_language => locale
      )
      UserMailer.reset_password_instructions(
        recipient,
        "__reset_password_token__"
      )
    end
  end
end
