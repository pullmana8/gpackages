json.packages @packages do |package|
  json.extract! package, :atom, :description
  json.href slf package_url(id: package.atom)
end
