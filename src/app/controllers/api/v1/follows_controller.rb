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
          render json: { message: "Successfully followed #{@user.username}." }, status: :created
        else
          render json: { errors: @follow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @follow = current_user.active_follows.find_by(following: @user)
        if @follow
          @follow.destroy
          render json: { message: "Successfully unfollowed #{@user.username}." }
        else
          render json: { error: "Not following this user." }, status: :not_found
        end
      end
      private

      def follow_params
        params.permit(:following_id) # following_id のみを受け取る
      end

      def set_user
        @user = User.find(params[:following_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "User not found." }, status: :not_found
      end
    end
  end
end