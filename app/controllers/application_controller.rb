class ApplicationController < ActionController::Base
  before_action :set_locale, :set_caching

  def set_locale
    I18n.locale = params[:hl] || I18n.default_locale
  rescue
    I18n.default_locale
  end

  def set_caching
    expires_in 10.minutes, public: true
  end
end
