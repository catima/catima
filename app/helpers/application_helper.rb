module ApplicationHelper
  def slug_help_text
    I18n.t('slug_help_text')
  end

  def base_class_name(model)
    model.class.name.split('::').first.downcase
  end

  def environment_clue
    return unless Rails.env.development? || (Rails.env.production? && current_user.system_admin?)

    env = ENV['CLUE_OVERRIDE'] || Rails.env.to_s.downcase
    content_tag(:div, env, :class => 'environment', :id => env)
  end
end
