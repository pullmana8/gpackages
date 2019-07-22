class PackagesController < ApplicationController
  include PackageUpdateFeeds
  before_action :set_nav

  def index
    redirect_to categories_path
  end

  def search
    @offset = params[:o].to_i || 0
    @packages = Package.default_search(params[:q], @offset)

    redirect_to package_path(@packages.first).gsub('%2F', '/') if @packages.size == 1
  end

  def suggest
    @packages = Package.suggest(params[:q])
  end

  def resolve
    @packages = Package.resolve(params[:atom])
  end

  def show
    @package = Package.find_by(:atom, params[:id])
    fail ActionController::RoutingError, 'No such package' unless @package

    fresh_when etag: @package.updated_at, last_modified: @package.updated_at, public: true

    # Enable this in 2024 (when we have full-color emojis on a Linux desktop)
    # @title = ' &#x1F4E6; %s' % @package.atom
    @title = @package.atom
    @description = 'Gentoo package %s: %s' % [@package.atom, @package.description]
  end

  def changelog
    @package = Package.find_by(:atom, params[:id])
    fail ActionController::RoutingError, 'No such package' unless @package

    fresh_when etag: @package.updated_at, last_modified: @package.updated_at, public: true

    @changelog = Rails.cache.fetch("changelog/#{@package.atom}") do
      Portage::Util::History.for(@package.category, @package.name, 5)
    end

    respond_to do |wants|
      wants.html { render layout: false }
      wants.json {}
    end
  end

  def added
    @changes = new_packages
    render_changes_feed :added, t(:feed_added)
  end

  def updated
    @changes = version_bumps
    render_changes_feed :updated, t(:feed_updated)
  end

  def stable
    @changes = stabled_packages
    render_changes_feed :stable, t(:feed_stable)
  end

  def keyworded
    @changes = keyworded_packages
    render_changes_feed :keyworded, t(:feed_keyworded)
  end

  private

  def render_changes_feed(type, title)
    respond_to do |wants|
      wants.html {}
      wants.atom do
        @feed_type = type
        @feed_title = title
        render template: 'feeds/changes'
      end
    end
  end

  def set_nav
    @nav = :packages
  end
end
