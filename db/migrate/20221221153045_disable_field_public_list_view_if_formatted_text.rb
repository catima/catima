class DisableFieldPublicListViewIfFormattedText < ActiveRecord::Migration[6.1]
  def change
    # Sanitize data, all fields having display_in_public_list set to true
    # must be human readable. Set this option to false if it's not the case.
    Field.where(display_in_public_list: true).find_each do |field|
      field.update(display_in_public_list: false) unless field.human_readable?
    end
  end
end
