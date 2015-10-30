module HasHumanId
  extend ActiveSupport::Concern

  module ClassMethods
    def human_id(attr, opts={})
      define_method(:to_param) do
        if (slug = send(attr).to_s).present?
          "#{id}-#{slug[0...opts.fetch(:truncate, 20)]}".parameterize
        else
          super()
        end
      end
    end
  end
end
