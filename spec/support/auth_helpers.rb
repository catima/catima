module AuthHelpers
  def generate_auth_header(user)
    "Bearer #{::Warden::JWTAuth::TokenEncoder.new.call({
                                                         'jti' => user.jti,
                                                         'sub' => user.id,
                                                         'scp' => "api_v3_user",
                                                         'aud' => nil
                                                       })}"
  end
end
