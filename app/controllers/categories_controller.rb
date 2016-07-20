class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :search]
  before_action :set_nav

  def index
    @categories = Category.all_sorted_by(:name, :asc)
  end

  def show
    @packages = Rails.cache.fetch("category/#{@category.name}/packages",
                                  expires_in: 10.minutes) do
      Package.find_all_by(:category,
                          @category.name,
                          sort: { name_sort: { order: 'asc' } }).map do |pkg|
        pkg.to_os(:name, :atom, :description)
      end
    end

    @description = t(:desc_categories_show,
                     category: @category.name,
                     description: @category.description)
  end

  def search
  end

  private

  def set_category
    @category = Category.find_by(:name, params[:id])
    fail ActionController::RoutingError, 'No such category' unless @category

    @title = @category.name
  end

  def set_nav
    @nav = :packages
  end
end
