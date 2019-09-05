class CommitsUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Portage::Util::History.update()
  end

end
