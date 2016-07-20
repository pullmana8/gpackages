json.extract! @category, :name
json.href slf category_url(id: @category.name)

json.packages @packages do |package|
  json.name package.name
  json.description package.description
  json.href slf(package_url(id: package.atom))
end

json.extract! @category, :updated_at