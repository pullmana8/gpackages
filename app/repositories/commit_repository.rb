require 'singleton'

class CommitRepository < BaseRepository
  include Singleton

  client ElasticsearchClient.default

  index_name "commit-#{Rails.env}"

  klass Commit

  mapping do
    indexes :id, type: 'keyword'
    indexes :author, type: 'keyword'
    indexes :email, type: 'keyword'
    indexes :date, type: 'date'
    indexes :message, type: 'text'
    indexes :files do
      indexes :modified, type: 'keyword'
      indexes :deleted, type: 'keyword'
      indexes :added, type: 'keyword'
    end
    indexes :packages, type: 'keyword'
    indexes :created_at, type: 'date'
    indexes :updated_at, type: 'date'
  end

end
