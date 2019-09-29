module PackageUpdateFeeds
  extend ActiveSupport::Concern

  def new_packages
    Rails.cache.fetch('new_packages', expires_in: 10.minutes) do
      ChangeRepository.find_all_by(:change_type, 'new_package', { size: 50, sort: { created_at: { order: 'desc' } } }).map do |change|
        change.to_os(:change_type, :package, :category, :created_at)
      end
    end
  end

  def version_bumps
    Rails.cache.fetch('version_bumps', expires_in: 10.minutes) do
      ChangeRepository.find_all_by(:change_type, 'version_bump', { size: 50, sort: { created_at: { order: 'desc' } } }).map do |change|
        change.to_os(:change_type, :package, :category, :version, :created_at)
      end
    end
  end

  def keyworded_packages
    Rails.cache.fetch('keyworded_packages', expires_in: 10.minutes) do
      ChangeRepository.find_all_by(:change_type, 'keyword', { size: 50, sort: { created_at: { order: 'desc' } } }).map do |change|
        change.to_os(:change_type, :package, :category, :version, :arches, :created_at)
      end
    end
  end

  def stabled_packages
    Rails.cache.fetch('stabled_packages', expires_in: 10.minutes) do
      ChangeRepository.find_all_by(:change_type, 'stable', { size: 50, sort: { created_at: { order: 'desc' } } }).map do |change|
        change.to_os(:change_type, :package, :category, :version, :arches, :created_at)
      end
    end
  end
end
