class UseflagsController < ApplicationController
  before_action :set_nav

  def index
    @title = t :use_flags
  end

  def show
    @useflags = UseflagRepository.get_flags(params[:id])

    if @useflags.empty? || (@useflags[:use_expand].empty? && @useflags[:local].empty? && @useflags[:global].empty?)
      fail ActionController::RoutingError, 'No such useflag'
    end

    @packages = PackageRepository.find_atoms_by_useflag(params[:id])
    @title = '%s – %s' % [params[:id], t(:use_flags)]

    unless @useflags[:use_expand].empty?
      @useflag = @useflags[:use_expand].first
      @use_expand_flags = UseflagRepository.find_all_by(:use_expand_prefix, @useflag.use_expand_prefix)
      @use_expand_flag_name = @useflag.use_expand_prefix.upcase

      render template: 'useflags/show_use_expand'
      return
    else
      render template: 'useflags/show'
    end
  end

  def search
    # TODO: Different search?
    @flags = UseflagRepository.suggest(params[:q])
  end

  def suggest
    @flags = UseflagRepository.suggest(params[:q])
  end

  def popular
    @popular_useflags = Rails.cache.fetch('popular_useflags', expires_in: 24.hours) do
      VersionRepository.get_popular_useflags(100)
    end
  end

  private

  def set_nav
    @nav = :use
  end
end
