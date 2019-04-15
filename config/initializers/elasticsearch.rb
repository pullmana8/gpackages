require 'elasticsearch/persistence'

DEFAULT_CLIENT = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_URL'] || 'localhost:9200'
$category = CategoryRepository.new(client: DEFAULT_CLIENT)
$package = PackageRepository.new(client: DEFAULT_CLIENT)
$change = Change.new(client: DEFAULT_CLIENT)

if Rails.env.development? or ENV['RAILS_DEBUG']
  logger           = ActiveSupport::Logger.new(STDERR)
  logger.level     = Logger::INFO
  logger.formatter = proc { |s, d, p, m| "\e[2m#{m}\n\e[0m" }
  DEFAULT_CLIENT.transport.logger = logger
end
