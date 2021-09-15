module HasDeletion
  extend ActiveSupport::Concern

  def not_deleted?
    deleted_at.nil?
  end

  module ClassMethods
    def not_deleted
      where(deleted_at: nil)
    end
  end
end
