class Users::RegistrationsController < Devise::RegistrationsController
  def user_scoped?
    true
  end
end
