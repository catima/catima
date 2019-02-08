module DeactivationHelper
  def deactivation_status_label(model)
    text, klass = model.active? ? %w(Active success) : %w(Inactive default)
    content_tag(:span, text, :class => "label label-#{klass}")
  end

  def deactivation_toggle(model, path_method, *args)
    options = args.extract_options!
    param = model.model_name.param_key

    at, icon = model.active? ? %w(now lock) : ["", "unlock"]
    label = model.active? ? t('deactivate') : t('reactivate')
    path = public_send(path_method, *args, param => { :deactivated_at => at })
    link_to(fa_icon(icon), path, options.reverse_merge(:method => :patch, :class => "btn btn-xs btn-default", "data-toggle" => "tooltip", "data-placement" => "top", "title" => label))
  end
end
