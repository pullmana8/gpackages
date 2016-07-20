class PackageUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    path, options = args
    package_model = Portage::Repository::Package.new(path)
    package_doc = Package.find_by(:atom, package_model.to_cp) || Package.new

    if package_doc.needs_import? package_model
      package_doc.import!(package_model, options)
    end
  end
end
