# app/controllers/api/v1/follows_controller.rb
module Api
  module V1
    class FollowsController < ApplicationController
      before_action :authorize_request # 認証処理を適用
      before_action :set_user, only: [:create, :destroy] # フォロー/アンフォロー対象のユーザーを取得

      def create
        # 自分が自分自身をフォローできないようにする
        if @user == current_user
          render json: { error: "You can't follow yourself." }, status: :bad_request
          return
        end

        # 既にフォローしている場合はエラーを返す
        if current_user.following?(@user)
          render json: { error: "Already following this user." }, status: :unprocessable_entity
          return
        end

        @follow = Follow.new(follower: current_user, following: @user) # current_user を follower に設定
        if @follow.save
          # フォローされたユーザーに通知を作成
          Notification.create(
            recipient_id: @user.id, # フォローされたユーザーのID
            sender_id: current_user.id, # フォローしたユーザーのID
            notifiable: @follow, # 通知対象をフォロー関係自身に設定
            notification_type: 'follow'
          )
          render json: { message: "Successfully followed #{@user.username}." }, status: :created
        else
          render json: { errors: @follow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # ...

    end
  end
end
```@follow.save` が成功した場合に、フォローされたユーザーへの通知を作成します。  
通知の受信者は `@user` (フォローされたユーザー)、送信者は `current_user` (フォローしたユーザー) となります。