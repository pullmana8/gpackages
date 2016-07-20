require 'sidekiq/web'

Rails.application.routes.draw do
  get 'about/feedback'
  post 'about/feedback'
  get 'about', to: 'about#index'
  get 'about/feeds'
  get 'about/help'
  get 'about/changelog'

  root 'index#index'

  # Catch all old pgo feeds
  get 'feed(/*stuff)', to: 'about#legacy', defaults: { format: 'atom' }

  resources :categories, only: [:index, :show, :search] do
    member do
      get 'search'
    end
  end

  resources :packages, only: [:index, :show, :search], constraints: { id: /[^.]*/ } do
    collection do
      get 'search'
      get 'suggest'
      get 'resolve'

      get 'added'
      get 'updated'
      get 'stable'
      get 'keyworded'
    end

    member do
      get 'changelog'
    end
  end

  resources :useflags do
    collection do
      get 'popular'
      get 'search'
      get 'suggest'
    end
  end

  resources :arches do
    member do
      get 'stable'
      get 'keyworded'
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'
end
