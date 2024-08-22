Warden::JWTAuth.configure do |config|
  config.secret = ENV.fetch('DEVISE_JWT_SECRET_KEY', nil)
  config.dispatch_requests = [
    ['POST', %r{^/api/v3/login$}],
    ['POST', %r{^/api/v3/login.json$}]
  ]
  config.revocation_requests = [
    ['DELETE', %r{^/api/v3/logout$}],
    ['DELETE', %r{^/api/v3/logout.json$}]
  ]
end
