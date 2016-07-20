class AboutController < ApplicationController
  before_action :set_nav

  def feedback
    if params.key? :feedback
      FeedbackMailer.feedback_email(params[:feedback], params[:contact]).deliver_now
      render text: 'Thank you for your feedback!', layout: 'application'
    end
  end

  def index
  end

  def feeds
  end

  def legacy
    @feed_type = 'legacy'
    @feed_title = 'packages.gentoo.org Legacy Feed'
  end

  private

  def set_nav
    @nav = :about
  end
end
