# See https://github.com/twitter/secureheaders#configuration
::SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: true,
    httponly: true,
    samesite: {
      lax: true
    }
  }

  config.hsts = "max-age=#{1.week.to_i}"
  config.x_frame_options = "SAMEORIGIN"
  config.x_xss_protection = "1; mode=block"
  config.x_content_type_options = "nosniff"
  config.x_download_options = 'noopen'
  config.x_permitted_cross_domain_policies = "none"
  config.csp = {
    default_src: %w(https: 'self'),
    script_src: %w('self' https: 'unsafe-eval' 'unsafe-inline'),
    style_src: %w('self' https: 'unsafe-inline'),
    img_src: %w('self' https: data:),
    font_src: %w('self' https: data:),
    object_src: %w('none'),
    connect_src: Rails.env.development? ? %w('self' https: http://localhost:3035 ws://localhost:3035) : %w('self' https:)
  }
end

