module Admin::UsersHelper
  def admin_catalogs(user)
    return content_tag(:span, "System", :class => "label label-default") if user.system_admin?
    user.admin_catalogs.map(&:name).to_sentence
  end

  def last_signed_in(user)
    at = [user.last_sign_in_at, user.current_sign_in_at].compact.max
    sentence_case("#{distance_of_time_in_words_to_now(at)} ago") unless at.nil?
  end
end
