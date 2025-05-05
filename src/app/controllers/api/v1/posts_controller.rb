module Api
  module V1
    class PostsController < ApplicationController
      before_action :authorize_request
      before_action :set_post, only: [:show, :update, :destroy]
      before_action :check_user_ownership, only: [:update, :destroy]

      def index
        if params[:user_id].present? && params[:is_liked_by_current_user] == 'true'
          user = User.find_by(id: params[:user_id])
          if user
            @posts = user.liked_posts.order(created_at: :desc).map do |post|
              user_icon_url = post.user.profile&.user_icon&.attached? ? url_for(post.user.profile.user_icon) : nil
              post.as_json(include: :user).merge(
                likes_count: post.likes.count,
                is_liked_by_current_user: current_user&.likes&.exists?(post_id: post.id),
                user_icon_url: user_icon_url
              )
            end
          else
            render json: { error: 'ユーザーが見つかりません' }, status: :not_found
            return
          end
        elsif params[:user_id].present?
          @posts = Post.where(user_id: params[:user_id]).order(created_at: :desc).map do |post|
            user_icon_url = post.user.profile&.user_icon&.attached? ? url_for(post.user.profile.user_icon) : nil
            post.as_json(include: :user).merge(
              likes_count: post.likes.count,
              is_liked_by_current_user: current_user&.likes&.exists?(post_id: post.id),
              user_icon_url: user_icon_url
            )
          end
        elsif params[:is_liked_by_current_user] == 'true'
          if current_user
            @posts = current_user.liked_posts.order(created_at: :desc).map do |post|
              user_icon_url = post.user.profile&.user_icon&.attached? ? url_for(post.user.profile.user_icon) : nil
              post.as_json(include: :user).merge(
                likes_count: post.likes.count,
                is_liked_by_current_user: true,
                user_icon_url: user_icon_url
              )
            end
          else
            render json: { error: 'ログインが必要です' }, status: :unauthorized
            return
          end
        else
          @posts = Post.all.order(created_at: :desc).map do |post|
            user_icon_url = post.user.profile&.user_icon&.attached? ? url_for(post.user.profile.user_icon) : nil
            post_data = post.as_json(include: { user: { include: :profile } })
            post_data.merge(
              likes_count: post.likes.count,
              is_liked_by_current_user: current_user&.likes&.exists?(post_id: post.id),
              user_icon_url: user_icon_url
            )
          end
        end
        render json: @posts
      end

      def show
        user_icon_url = @post.user.profile&.user_icon&.attached? ? url_for(@post.user.profile.user_icon) : nil
        render json: @post.as_json(include: :user).merge(
          likes_count: @post.likes.count,
          is_liked_by_current_user: current_user&.likes&.exists?(post_id: @post.id),
          user_icon_url: user_icon_url # ここで追加
        )
      end

      def create
        @post = current_user.posts.new(post_params)
        if @post.save
          render json: @post, status: :created
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @post.update(post_params)
          render json: @post
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @post.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: '投稿が見つかりません' }, status: :not_found
      end

      def post_params
        params.require(:post).permit(:content, :post_type, :media_url)
      end

      def check_user_ownership
        unless @post.user_id == current_user.id
          render json: { error: '許可されていません' }, status: :forbidden
        end
      end
    end
  end
end