module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_request, except: [:create]
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        @users = User.all.map do |user|
          user_data = user.attributes.except('password_digest')
          if user.profile&.user_icon&.attached? # ここを user_icon に修正
            user_data[:user_icon_url] = url_for(user.profile.user_icon) # ここを user_icon に修正
          end
          user_data
        end
        render json: @users
      end

      def show
        user_data = @user.attributes.except('password_digest')
        if @user.profile&.user_icon&.attached? # ここを user_icon に修正
          user_data[:user_icon_url] = url_for(@user.profile.user_icon) # ここを user_icon に修正
        end
        render json: user_data
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user, status: :created
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def update
        if @user.update(user_params)
          user_data = @user.attributes.except('password_digest')
          if @user.profile&.user_icon&.attached? # ここを user_icon に修正
            user_data[:user_icon_url] = url_for(@user.profile.user_icon) # ここを user_icon に修正
          end
          render json: user_data
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @user.destroy
        render json: { message: 'User deleted successfully' }
      end

      private

      def set_user
        @user = User.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def user_params
        params.require(:user).permit(:email, :password, :username, :display_name, :avatar)
      end
    end
  end
end