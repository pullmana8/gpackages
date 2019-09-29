class PackageRemovalJob < ApplicationJob
  queue_as :default

  def perform(*args)
    atom, _options = args

    package_doc = Package.find_by(:atom, atom)
    return if package_doc.nil?

    package_doc.versions.each(&:delete)
    package_doc.delete

    Rails.logger.warn { "Package deleted: #{atom}" }
    # USE flags are cleaned up by the UseflagsUpdateJob
  end
end
