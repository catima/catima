class ChangeChoiceNameColumnsToJson < ActiveRecord::Migration[4.2]
  class Catalog < ActiveRecord::Base
  end

  class ChoiceSet < ActiveRecord::Base
    belongs_to :catalog, :class_name => "ChangeChoiceNameColumnsToJson::Catalog"
  end

  class Choice < ActiveRecord::Base
    belongs_to :choice_set,
               :class_name => "ChangeChoiceNameColumnsToJson::ChoiceSet"
  end

  def up
    rename_column :choices, :short_name, :short_name_old
    rename_column :choices, :long_name, :long_name_old
    add_column :choices, :short_name, :json
    add_column :choices, :long_name, :json

    Choice.find_each do |ch|
      locale = ch.choice_set.catalog.primary_language
      ch.update_columns(
        :short_name => { "short_name_#{locale}" => ch.short_name_old },
        :long_name => { "long_name_#{locale}" => ch.long_name_old }
      )
    end
  end

  def down
    remove_column :choices, :short_name
    remove_column :choices, :long_name
    rename_column :choices, :short_name_old, :short_name
    rename_column :choices, :long_name_old, :long_name
  end
end
