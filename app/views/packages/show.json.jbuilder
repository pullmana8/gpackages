json.extract! @package, :atom, :description
json.href slf package_url(id: @package.atom)

json.versions @package.versions do |version|
  json.version version.version
  json.keywords version.keywords
  json.masks version.masks
end

json.maintainers @package.maintainers do |maintainer|
  json.email maintainer['email']
  json.name maintainer['name']
  json.description maintainer['description']
  json.type maintainer['type']

  if maintainer['type'] == 'project'
    json.members project_members(maintainer['email'])
  end
end

json.use do
  json.local @package.versions.first.useflags[:local] do |flag|
    json.name flag[1][:name]
    json.description strip_tags flag[1][:description]
  end

  json.global @package.versions.first.useflags[:global] do |flag|
    json.name flag[1][:name]
    json.description strip_tags flag[1][:description]
  end

  json.use_expand @package.versions.first.useflags[:use_expand] do |flag|
    json.set! flag[0] do
      json.array! flag[1] do |expand_flag|
        json.name expand_flag[0]
        json.description strip_tags expand_flag[1][:description]
      end
    end
  end
end

json.extract! @package, :updated_at
