Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "authentication/login"
      get "authentication/logout"

      post '/login', to: 'authentication#login'
      post '/logout', to: 'authentication#logout'

      resources :users
      resources :profiles, only: [:show, :update] # 複数形に変更
      resources :posts
      resources :likes, only: [:create, :destroy]
      resources :comments, only: [:create, :destroy]
      resources :follows, only: [:create, :destroy]
      resources :conversations
      resources :conversation_users, only: [:create, :destroy]
      resources :messages
      resources :notifications
    end
  end
end