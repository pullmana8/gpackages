class UseflagsUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    repo = Portage::Repository::Model.new KKULEOMI_PORTDIR

    update_global repo
    update_use_expand repo
  end

  def update_global(repo)
    model_flags = repo.global_useflags
    index_flags = UseflagRepository.global

    new_flags = model_flags.keys - index_flags.keys
    del_flags = index_flags.keys - model_flags.keys
    eql_flags = model_flags.keys & index_flags.keys

    new_flags.each do |flag|
      flag_doc = Useflag.new
      flag_doc.name = flag
      flag_doc.description = model_flags[flag]
      flag_doc.scope = 'global'
      UseflagRepository.save(flag_doc)
    end

    eql_flags.each do |flag|
      unless index_flags[flag].description == model_flags[flag]
        index_flags[flag].description = model_flags[flag]
        UseflagRepository.save(index_flags[flag])
      end
    end

    del_flags.each do |flag|
      UseflagRepository.delete(index_flags[flag])
    end
  end

  def update_use_expand(repo)
    model_flags = repo.use_expand_flags
    index_flags = UseflagRepository.use_expand

    # Calculate keys only once
    index_flag_keys = index_flags.keys

    # Record processed flags to find deletion candidates
    flag_status = Hash[index_flag_keys.map {|key| [key, false] }]

    model_flags.each_pair do |variable, values_hsh|
      values_hsh.each_pair do |flag, desc|
        _flag = '%s_%s' % [variable, flag]
        flag_status[_flag] = true

        # Already present ones
        if index_flag_keys.include? _flag
          unless index_flags[_flag].description == desc
            index_flags[_flag].description = desc
            UseflagRepository.save(index_flags[_flag])
          end
        else
          # New flag
          flag_doc = Useflag.new
          flag_doc.name = _flag
          flag_doc.description = desc
          flag_doc.scope = 'use_expand'
          flag_doc.use_expand_prefix = variable
          UseflagRepository.save(flag_doc)
        end
      end
    end

    # Find and process removed flags
    flag_status.each_pair do |flag, status|
      UseflagRepository.delete(index_flags[flag]) unless status
    end
  end

end
