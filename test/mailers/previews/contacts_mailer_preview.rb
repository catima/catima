# Preview all emails at http://localhost:3000/rails/mailers/invitations_mailer
class ContactsMailerPreview < ActionMailer::Preview
  # Use meta-programming to define multiple methods for each locale
  %w(de en fr it).each do |locale|
    # Preview this email at
    # http://localhost:3000/rails/mailers/user_mailer/reset_password_instructions_en
    define_method("send_request_#{locale}") do
      recipient = User.new(
        :email => "matt@mattbrictson.com",
        :primary_language => locale
      )
      ContactMailer.send_request(
        recipient.email,
        "name" => "fake name",
        "email" => "email@email.com",
        "body" => "request's body"
      )
    end
  end
end
