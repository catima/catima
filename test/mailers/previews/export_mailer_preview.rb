# Preview all emails at http://localhost:3000/rails/mailers/export_mailer
class ExportMailerPreview < ActionMailer::Preview
  %w(de en fr it).each do |locale|
    # Preview this email at
    # http://localhost:3000/rails/mailers/export_mailer/export_available_en
    define_method("export_available_#{locale}") do
      catalog = Catalog.first_or_create!(
        :name => "Sample",
        :slug => "sample",
        :primary_language => "en"
      )
      user = User.new(
        :email => "john@doe.com",
        :primary_language => locale
      )
      export = Export.new(
        :id => 1,
        :user => user,
        :catalog => catalog,
        :category => "catima",
        :status => "ready",
        :created_at => Time.zone.now,
        :updated_at => Time.zone.now
      )
      ExportMailer.send_message(export)
    end
  end
end
