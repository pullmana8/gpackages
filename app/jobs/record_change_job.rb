class RecordChangeJob < ApplicationJob
  queue_as :default

  # Creates a Change object for the given data
  def perform(args)
    c = Change.new
    c.package = args[:package]
    c.category = args[:category]
    c.actor = args[:actor] if args.has_key? :actor

    if args[:type] == 'new_package'
      c.change_type = 'new_package'
    elsif args[:type] == 'version_bump'
      c.change_type = 'version_bump'
      c.version = args[:version]
    elsif args[:type] == 'stable'
      c.change_type = 'stable'
      c.version = args[:version]
      c.arches = args[:arches]
    elsif args[:type] == 'keyword'
      c.change_type = 'keyword'
      c.version = args[:version]
      c.arches = args[:arches]
    elsif args[:type] == 'package_removed'
      c.change_type = 'removal'
    end

    ChangeRepository.save(c)
  end
end
