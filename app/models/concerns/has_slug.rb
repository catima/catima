module HasSlug
  extend ActiveSupport::Concern

  def to_param
    slug
  end

  module ClassMethods
    def validates_slug(options={})
      validates_presence_of :slug
      validates_uniqueness_of :slug, options
      validates_length_of :slug, :minimum => 3

      validates_format_of :slug,
                          :with => /\A[a-z0-9\-]*\z/,
                          :message => "must contain only a-z, 0-9, and hyphens"

      %w(admin manage new edit api).each do |reserved|
        validates_format_of \
          :slug,
          :without => /\A#{reserved}\z/,
          :message => "“#{reserved}” is reserved and cannot be used"
      end
    end
  end
end
