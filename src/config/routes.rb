Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "authentication/login"
      get "authentication/logout"

      post '/login', to: 'authentication#login'
      post '/logout', to: 'authentication#logout'

      resources :users
      resources :profiles, only: [:show, :update]
      resources :posts do
        resources :comments, only: [:index, :create] # posts にネスト
      end
      resources :likes, only: [:create, :destroy]
      resources :comments, only: [:destroy] # コメント ID で削除
      resources :follows, only: [:create, :destroy]
      resources :conversations
      resources :conversation_users, only: [:create, :destroy]
      resources :messages
      resources :notifications
    end
  end
end