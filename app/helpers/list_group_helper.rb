module ListGroupHelper
  # Just like navbar_link_to, except for linked list group items.
  def list_group_link_to(label, path, options={})
    active_when = options.delete(:active_when) { Hash.new }
    active = active_when.all? do |key, value|
      value === params[key].to_s
    end

    klass = [options[:class], "list-group-item"].compact.join(" ")
    klass << " active" if active

    link_to(label, path, options.merge(:class => klass))
  end
end
