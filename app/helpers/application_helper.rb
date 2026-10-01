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

    env = ENV['CLUE_OVERRIDE'].presence || Rails.env.to_s.downcase
    tag.div(env, :class => 'environment', :id => env)
  end

  def partial_exists?(partial_path)
    lookup_context.find_all(partial_path, [], true).any?
  end

  def current_messages(context, catalog=nil)
    dismissed_ids = Array(session[:dismissed_messages])
    scope = Message.active
                   .for_catalog(catalog)
                   .send("for_#{context}")
                   .by_severity_and_date
    return scope if dismissed_ids.empty?

    scope.where.not(id: dismissed_ids)
  end

  def catalog_role_label(role, no_access: false)
    return role.capitalize unless no_access

    safe_join(
      [
        fa_icon(:ban, class: "role-no-access-icon", aria: { hidden: true }),
        role.capitalize,
        tag.span(t("catalog_admin.users.no_access_role_tooltip"), class: "visually-hidden")
      ],
      " "
    )
  end

  def catalog_role_tooltip_attributes(no_access)
    return {} unless no_access

    {
      :data => { :toggle => "tooltip", :placement => "top" },
      :title => t("catalog_admin.users.no_access_role_tooltip")
    }
  end
end
