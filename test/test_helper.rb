ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Import some test data into the test indices
  category = Portage::Repository::Category.new('test/fixtures/repo/virtual')
  Category.new.import!(category)

  # Add more helper methods to be used by all tests here...
end
