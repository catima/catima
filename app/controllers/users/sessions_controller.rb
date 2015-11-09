class Users::SessionsController < Devise::SessionsController
  # This small hack lets us remember the stored location when the user logs out.
  # Normally, since Devise clears the session upon logout, the stored location
  # is wiped. To work around this, we re-store the value after logout but before
  # the redirect.
  def destroy
    after_path = stored_location_for(:user)
    super do
      # This blocks executes after logout, but before redirect.
      store_location_for(:user, after_path)
    end
  end
end
