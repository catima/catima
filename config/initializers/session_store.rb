# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cache_store,
                                       key: '_catima_session',
                                       expire_after: 90.minutes
