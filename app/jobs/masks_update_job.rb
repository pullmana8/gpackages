class MasksUpdateJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Portage::Util::Masks.update!
  end
end
