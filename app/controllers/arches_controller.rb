class ArchesController < ApplicationController
  before_action :set_nav
  before_action :set_arch, only: [:show, :added, :updated, :stable, :keyworded]

  def index
  end

  def show
  end

  def stable
    @changes = stabled_packages @arch
    render_changes_feed :stable, t(:feed_stable_arch, arch: @arch)
  end

  def keyworded
    @changes = keyworded_packages @arch
    render_changes_feed :keyworded, t(:feed_keyworded, arch: @arch)
  end

  private

  def set_nav
    @nav = :arches
  end

  def set_arch
    fail ActionController::RoutingError, 'No such architecture' unless ::KKULEOMI_ARCHES.include? params[:id]
    @arch = params[:id]
    @feed_id = @arch
  end

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

  def keyworded_packages(arch)
    Rails.cache.fetch("keyworded_packages/#{arch}", expires_in: 10.minutes) do
      ChangeRepository.filter_all({ change_type: 'keyword', arches: arch },
                                  size: 50,
                                  sort: { created_at: { order: 'desc' } }).map do |change|
        change.to_os(:change_type, :package, :category, :version, :arches, :created_at)
      end
    end
  end

  def stabled_packages(arch)
    Rails.cache.fetch("stabled_packages/#{arch}", expires_in: 10.minutes) do
      ChangeRepository.filter_all({ change_type: 'stable', arches: arch },
                                  size: 50,
                                  sort: { created_at: { order: 'desc' } }).map do |change|
        change.to_os(:change_type, :package, :category, :version, :arches, :created_at)
      end
    end
  end
end
