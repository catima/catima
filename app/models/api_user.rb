class APIUser < User
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :jwt_authenticatable, jwt_revocation_strategy: APIUser

  validates :jti, presence: true

  def generate_jwt
    JWT.encode({ id: id, exp: 1.day.from_now.to_i },
               Rails.env.devise.jwt.secret_key)
  end
end
