class CustomFailureApp < Devise::FailureApp
  def respond
    if warden_options[:scope] == :api_v3_user
      self.status = 401
      self.content_type = 'json'
      request.original_fullpath == "/api/v3/login" ? self.response_body = '{"message": "Authentication error","code": "authentication_error"}' : self.response_body = '{"message": "Invalid authentication token","code": "invalid_token"}'
    elsif http_auth?
      http_auth
    elsif warden_options[:recall]
      recall
    else
      redirect
    end
  end
end

