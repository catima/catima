module DeactivationHelper
  def deactivation_status_label(model)
    text, klass = model.active? ? %w(Active success) : %w(Inactive default)
    content_tag(:span, text, :class => "label label-#{klass}")
  end

  def deactivation_toggle(model, path_method, *args)
    options = args.extract_options!
    param = model.model_name.param_key

    label, at = model.active? ? %w(Deactivate now) : ["Reactivate", ""]
    path = public_send(path_method, *args, param => { :deactivated_at => at })
    link_to(label, path, options.reverse_merge(:method => :patch))
  end
end
