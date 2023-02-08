class DisableFieldPublicListViewIfFormattedText < ActiveRecord::Migration[6.1]
  # ⚠️ This migration was created in PR #484 and updated later.
  #
  # The first version was not correct because it set "display_in_public_list" to
  # false to all image fields and should not have.
  #
  # The second version was also incorrect. The filterable fields are still
  # displayed in summary although they're not human readable.
  # The formatting is removed when the field is displayed.
  #
  # We must be careful that in-between the creation and the correction of this
  # migration, doing migrations will lead to incorrect data.
  #
  # PR #484 https://github.com/catima/catima/pull/484

  def change
    # Sanitize data, all fields having display_in_public_list set to true
    # must be human readable. Set this option to false if it's not the case.
    Field.where(display_in_public_list: true).find_each do |field|
      next if field.human_readable?

      next if field.filterable?

      next if field.is_a?(Field::Image)

      field.update(display_in_public_list: false)
    end
  end
end
