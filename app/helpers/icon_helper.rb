module IconHelper
  def prepend_icon_if(condition, icon, label=nil, &block)
    label = capture(&block) if block
    condition ? fa_icon(icon, :text => label) : label
  end
end
