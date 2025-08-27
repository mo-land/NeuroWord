Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  # resources :static_pages
  root "static_pages#top"

  get "search_tag"=>"questions#search_tag"

  resource :user, only: [ :edit, :update ] do
    member do
      get :mypage  # 必要に応じて
    end
  end

  resources :questions, only: %i[index new create show edit update destroy] do
    resources :card_sets
  end

  # ゲーム関連ルート
  resources :games, only: [ :show ] do
    member do
      post :check_match
      get :result
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
