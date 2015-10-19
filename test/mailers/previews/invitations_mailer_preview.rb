# Preview all emails at http://localhost:3000/rails/mailers/invitations_mailer
class InvitationsMailerPreview < ActionMailer::Preview
  # Use meta-programming to define multiple methods for each locale
  %w(de en fr it).each do |locale|
    # Preview this email at
    # http://localhost:3000/rails/mailers/invitations_mailer/catalog_admin_en
    define_method("catalog_admin_#{locale}") do
      catalog = Catalog.first_or_create!(
        :name => "Sample",
        :slug => "sample",
        :primary_language => "en"
      )
      sender = User.new(:email => "ck@naxio.ch")
      recipient = User.new(
        :email => "matt@mattbrictson.com",
        :primary_language => locale,
        :invited_by => sender,
        :system_admin => false,
        :catalog_permissions => [
          CatalogPermission.new(:catalog => catalog, :role => "admin")
        ]
      )
      InvitationsMailer.admin(recipient, "__reset_password_token__")
    end

    # Preview this email at
    # http://localhost:3000/rails/mailers/invitations_mailer/system_admin_en
    define_method("system_admin_#{locale}") do
      sender = User.new(:email => "ck@naxio.ch")
      recipient = User.new(
        :email => "matt@mattbrictson.com",
        :primary_language => locale,
        :invited_by => sender,
        :system_admin => true
      )
      InvitationsMailer.admin(recipient, "__reset_password_token__")
    end

    # Preview this email at
    # http://localhost:3000/rails/mailers/invitations_mailer/user_en
    define_method("user_#{locale}") do
      catalog = Catalog.first_or_create!(
        :name => "Sample",
        :slug => "sample",
        :primary_language => "en"
      )
      sender = User.new(:email => "ck@naxio.ch")
      recipient = User.new(
        :email => "matt@mattbrictson.com",
        :primary_language => locale,
        :invited_by => sender,
        :catalog_permissions => [
          CatalogPermission.new(:catalog => catalog, :role => "editor")
        ]
      )
      InvitationsMailer.user(recipient, catalog, "__reset_password_token__")
    end
  end
end
