class CustomFailureApp < Devise::FailureApp
  def respond
    if warden_options[:scope] == :api_v3_user
      self.status = 401
      self.content_type = 'json'
      self.response_body = if request.original_fullpath == "/api/v3/login"
                             '{"message": "Authentication error","code": "authentication_error"}'
                           else
                             '{"message": "Invalid authentication token","code": "invalid_token"}'
                           end
    elsif http_auth?
      http_auth
    elsif warden_options[:recall]
      recall
    else
      redirect
    end
  end
end
