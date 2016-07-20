class IndexController < ApplicationController
  include PackageUpdateFeeds

  def index
    @nav = :index

    @new_packages = new_packages[0..9]
    @version_bumps = version_bumps[0..9]
  end
end
