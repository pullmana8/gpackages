source 'https://rubygems.org'

# IMPORTANT (antonette)
# Upgrade to 4.2 stable first before making upgrade to 5.2.3
# Testing 5.2.3 on different branch, dirs/files are different
gem 'rails', '4.2.11.1'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'nokogiri'
gem 'parallel'
gem 'ruby-progressbar'
gem 'git'
gem 'thin'

# IMPORTANT (antonette)
# Remove false
gem 'sinatra'
gem 'sidekiq'

gem 'rdiscount'

gem 'octicons_helper'
group :development do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

# IMPORTANT (antonette)
# Tested earlier versions, and keeping ES on branch 6.x
# ActiveModel feature is deprecated
# Use Repository feature now
gem 'elasticsearch-model', github: 'elastic/elasticsearch-rails', branch: '6.x'
gem 'elasticsearch-rails', github: 'elastic/elasticsearch-rails', branch: '6.x'
gem 'elasticsearch-persistence', git: 'git://github.com/elastic/elasticsearch-rails.git', branch: '6.x'
gem 'virtus'