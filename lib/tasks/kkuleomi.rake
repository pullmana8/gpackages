namespace :kkuleomi do
  namespace :index do
    desc '(Re-)Initializes the ElasticSearch index'
    task init: :environment do
      Kkuleomi::Store.create_index true
    end
  end

  namespace :update do
    desc 'Updates all data'
    task all: :environment do
      run_update(false)
    end

    desc 'Update global USE and USE_EXPAND flags'
    task use: :environment do
      UseflagsUpdateJob.perform_later
    end

    desc 'Update internal mask cache in the delayed job runner process'
    task masks: :environment do
      MasksUpdateJob.perform_later
    end
  end

  namespace :seed do
    desc 'Initially seeds all data'
    task all: :environment do
      run_update(true)
    end
  end
end

def run_update(no_change_objects)
  initialize_caches

  fail 'Invalid work dir!' unless File.directory? KKULEOMI_PORTDIR
  repo = Portage::Repository::Model.new KKULEOMI_PORTDIR

  options = {
    suppress_change_objects: no_change_objects
  }

  Rails.cache.write(KK_CACHE_LAST_IMPORT, Time.now)
  repo.categories.each do |category|
    CategoryUpdateJob.perform_later(category.path, options)
  end
end

def initialize_caches
  MasksUpdateJob.perform_later
  UseflagsUpdateJob.perform_later
end
