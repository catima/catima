# Ensure that there is one (and only one) configuration
Configuration.first_or_create!

# Ensure at least one user
admin = User.first_or_create!(
  :email => "admin@example.com",
  :password => "admin123",
  :password_confirmation => "admin123",
  :system_admin => true,
  :primary_language => "en"
)

if Rails.env.development?
  # Create a "Library" catalog with lots of fake books for search testing.
  library = Catalog.where(:slug => "library").first_or_create!(
    :name => "Library",
    :primary_language => "en"
  )

  books = library.item_types.where(:slug => "book").first_or_create!(
    :catalog => library,
    :name_en => "Book",
    :name_plural_en => "Books"
  )

  fields = %w(Title Author Publisher Genre).each_with_index.map do |name, index|
    books.fields.where(:slug => name.downcase).first_or_create!(
      :type => "Field::Text",
      :name_en => name,
      :name_plural_en => name.pluralize,
      :primary => (index == 0),
      :display_in_list => true
    )
  end

  if books.items.none?
    require "faker"
    require "ruby-progressbar"

    puts "Creating books..."

    bar = ProgressBar.create(
      :total => 1_000,
      :format => "%c/%C: [%B] %p%% %a, %e",
      :progress_mark => "\e[0;32;49m=\e[0m"
    )

    1_000.times do
      book = books.items.new.behaving_as_type
      book.catalog = library
      book.creator = admin

      fields.each do |field|
        fake_value = Faker::Book.public_send(field.slug)
        book.public_send("#{field.uuid}=", fake_value)
      end

      book.save!
      bar.increment
    end
  end
end
