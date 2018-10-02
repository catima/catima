class Users::RegistrationsController < Devise::RegistrationsController
  def user_scoped?
    true
  end

  protected

  def update_resource(resource, params)
    # If the user has authenticated using an OmniAuth provider,
    # we don't ask the password to change the email address.
    if resource.provider.blank?
      resource.update_with_password(params)
    else
      resource.update_without_password(params)
    end
  end
end
