# Preview all emails at http://localhost:3000/rails/mailers/invitations_mailer
class InvitationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invitations_mailer/catalog_admin
  def catalog_admin
    catalog = Catalog.first_or_create!(
      :name => "Sample",
      :slug => "sample",
      :primary_language => "en"
    )
    sender = User.new(:email => "ck@naxio.ch")
    recipient = User.new(
      :email => "matt@mattbrictson.com",
      :invited_by => sender,
      :system_admin => false,
      :catalog_permissions => [
        CatalogPermission.new(:catalog => catalog, :role => "admin")
      ]
    )
    InvitationsMailer.admin(recipient, "__reset_password_token__")
  end

  # Preview this email at http://localhost:3000/rails/mailers/invitations_mailer/system_admin
  def system_admin
    sender = User.new(:email => "ck@naxio.ch")
    recipient = User.new(
      :email => "matt@mattbrictson.com",
      :invited_by => sender,
      :system_admin => true
    )
    InvitationsMailer.admin(recipient, "__reset_password_token__")
  end

  # Preview this email at http://localhost:3000/rails/mailers/invitations_mailer/user
  def user
    catalog = Catalog.first_or_create!(
      :name => "Sample",
      :slug => "sample",
      :primary_language => "en"
    )
    sender = User.new(:email => "ck@naxio.ch")
    recipient = User.new(
      :email => "matt@mattbrictson.com",
      :invited_by => sender,
      :catalog_permissions => [
        CatalogPermission.new(:catalog => catalog, :role => "editor")
      ]
    )
    InvitationsMailer.user(recipient, catalog, "__reset_password_token__")
  end
end
