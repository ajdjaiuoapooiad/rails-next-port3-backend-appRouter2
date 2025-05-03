module Api
  module V1
    class ProfilesController < ApplicationController
      before_action :authorize_request
      before_action :set_profile, only: [:update]
      before_action :set_user_for_show, only: [:show]

      def show
        profile_data = @user.profile.as_json(only: [:bio, :location, :website, :display_name, :created_at, :updated_at])
        profile_data[:id] = @user.id
        profile_data[:username] = @user.username
        profile_data[:email] = @user.email
        if @user.profile.user_icon.attached?
          profile_data[:user_icon_url] = url_for(@user.profile.user_icon)
        end
        if @user.profile.bg_image.attached?
          profile_data[:bg_image_url] = url_for(@user.profile.bg_image)
        end

        # ログインしているユーザーがいる場合、フォロー状態を確認してレスポンスに追加
        if current_user
          profile_data[:is_following] = current_user.following?(@user)
        else
          profile_data[:is_following] = false # ログインしていない場合はフォローしていないとみなす
        end

        render json: profile_data
      end

      def update
        if @profile.update(profile_params)
          profile_data = @profile.as_json
          profile_data[:username] = @profile.user.username
          profile_data[:email] = @profile.user.email
          if @profile.user_icon.attached?
            profile_data[:user_icon_url] = url_for(@profile.user_icon)
          end
          if @profile.bg_image.attached?
            profile_data[:bg_image_url] = url_for(@profile.bg_image)
          end
          render json: profile_data
        else
          render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user_for_show
        @user = User.find_by(id: params[:id])
        unless @user
          render json: { message: 'ユーザーが見つかりません' }, status: :not_found
        end
      end

      def set_profile
        @profile = current_user.profile
        unless @profile
          render json: { message: 'プロフィールが見つかりません' }, status: :not_found
        end
      end

      def profile_params
        params.permit(:bio, :location, :website, :user_icon, :bg_image, :display_name)
      end
    end
  end
end