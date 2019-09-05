class PackageRemovalJob < ApplicationJob
  queue_as :default

  def perform(*args)
    atom, _options = args

    package_doc = PackageRepository.find_by(:atom, atom)
    return if package_doc.nil?

    package_doc.versions.each { |v| VersionRepository.delete(v) }
    PackageRepository.delete(package_doc)

    Rails.logger.warn { "Package deleted: #{atom}" }
    # USE flags are cleaned up by the UseflagsUpdateJob
  end
end
