require 'sidekiq'

Sidekiq.configure_server do |config|
	config.redis = { url: ENV.fetch("REDIS_URL", 'localhost:6379' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", 'localhost:6379' }
end

if Rails.env.production?
	Sidekiq::Logging.logger.level = Logger::WARN
end