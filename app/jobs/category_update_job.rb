class CategoryUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    category_path, options = args

    model = Portage::Repository::Category.new(category_path)
    category = Category.find_by(:name, model.name) || Category.new
    idx_packages = Package.find_all_by(:category, model.name) || []

    if category.needs_import? model
      category.import! model
    end

    idx_package_map = Hash[idx_packages.map { |p| [p.name, p] }]
    model_package_map = Hash[model.packages.map { |p| [p.name, p] }]

    idx_keys = idx_package_map.keys
    model_keys = model_package_map.keys

    new_p = model_keys - idx_keys
    eql_p = model_keys & idx_keys
    del_p = idx_keys - model_keys

    new_p.each do |pkg_name|
      PackageUpdateJob.perform_later model_package_map[pkg_name].path, options.merge(package_state: 'new')
    end

    eql_p.each do |pkg_name|
      if idx_package_map[pkg_name].needs_import? model_package_map[pkg_name]
        PackageUpdateJob.perform_later model_package_map[pkg_name].path, options.merge(package_state: 'existing')
      end
    end

    del_p.each do |pkg_name|
      PackageRemovalJob.perform_later '%s/%s' % [category.name, pkg_name]
    end
  end
end
