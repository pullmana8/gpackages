# This file is used by Rack-based servers to start the application.
require "rubygems"
require "geminabox"

Geminabox.data = "./data"
run Geminabox::Server

require ::File.expand_path("../config/environment', __FILE__")
run Rails.application
