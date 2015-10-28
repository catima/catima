class PopulateExistingChoiceSetCatalog < ActiveRecord::Migration
  class ChoiceSet < ActiveRecord::Base
  end

  class Choice < ActiveRecord::Base
    belongs_to :choice_set,
               :class_name => "PopulateExistingChoiceSetCatalog::ChoiceSet"
  end

  def up
    Choice.find_each do |choice|
      choice.update_column(:catalog_id, choice.choice_set.catalog_id)
    end
  end

  def down
    # pass
  end
end
