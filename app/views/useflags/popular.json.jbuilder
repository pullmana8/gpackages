json.name 'flags'
json.children @popular_useflags do |flag|
  # Very cheap filter for USE_EXPAND flags
  next if flag['key'].include? '_'
  next if flag['key'] =~ /^(doc|test|debug)$/

  json.name flag['key']
  json.size flag['doc_count']
  json.children  nil
end
