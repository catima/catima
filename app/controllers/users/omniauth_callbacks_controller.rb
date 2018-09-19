class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    sign_in_from_provider(:facebook, request.env['omniauth.auth'])
  end

  def github
    sign_in_from_provider(:github, request.env['omniauth.auth'])
  end

  def shibboleth
    sign_in_from_provider(:shibboleth, request.env('omniauth.auth'))
  end

  def sign_in_from_provider(provider, auth)
    @user = User.from_omniauth(auth)
    if @user.persisted?
      if @user.email_complete?
        sign_in_and_redirect @user, event: :authentication
      else
        sign_in @user, event: :authentication
        redirect_to edit_user_registration_path unless @user.email_complete?
      end
      set_flash_message(:notice, :success, kind: provider.capitalize.to_s) if is_navigational_format?
    else
      # Not possible to create the user. Display a message and redirect to user registration page.
      session["devise.omniauth_data"] = auth
      set_flash_message(:alert, :failure, kind: provider.capitalize.to_s, reason: 'invalid user')
      redirect_to new_user_registration_url
    end
  end

  def failure
    set_flash_message(
      :alert,
      :failure,
      kind: request.env['omniauth.auth'] && request.env['omniauth.auth'].provider.capitalize.to_s || 'unknown',
      reason: 'wrong credentials'
    )
    redirect_to root_path
  end
end
