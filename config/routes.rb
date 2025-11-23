Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  # resources :static_pages
  root "static_pages#top"
  get "/terms" => "static_pages#terms"
  get "/privacy_policy" => "static_pages#privacy_policy"
  get "/contact" => "static_pages#contact"
  
  resource :user, only: %i[] do
    member do
      get :mypage  # 必要に応じて
    end
  end

  resources :questions, only: %i[index new create show edit update destroy] do
    resources :card_sets,  only: %i[new create edit update destroy] do
      resources :related_words,  only: %i[new create edit update destroy]
    end
    resource :list_questions, only: %i[create destroy] do
      patch :update_multiple, on: :collection
    end
    collection do
      get :autocomplete
    end
  end

  resources :games, only: [ :show ] do
    member do
      post :check_match
    end
  end

  resources :game_records, only: %i[create show] do
    collection do
      get :batch_results
    end
  end
  resources :requests, only: %i[index new create show] do
    resources :request_responses, only: %i[create], shallow: true
  end

  resources :lists, only: %i[new create edit update destroy] do
    member do
      get :batch_play
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


  # Defines the root path route ("/")
  # root "posts#index"
end
