module ApplicationHelper
  def slug_help_text
    I18n.t('slug_help_text')
  end

  def base_class_name(model)
    model.class.name.split('::').first.downcase
  end

  def environment_clue
    return unless
        Rails.env.development? ||
        Rails.env.staging? ||
        (Rails.env.production? && current_user.system_admin?)

    env = ENV['CLUE_OVERRIDE'] || Rails.env.to_s.downcase
    tag.div(env, :class => 'environment', :id => env)
  end

  def partial_exists?(partial_path)
    lookup_context.find_all(partial_path, [], true).any?
  end
end
