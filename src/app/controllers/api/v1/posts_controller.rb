module Api
  module V1
    class PostsController < ApplicationController
      before_action :authorize_request
      before_action :set_post, only: [:show, :update, :destroy]

      def index
        @posts = Post.all.order(created_at: :desc).map do |post|
          post.as_json(include: :user).merge( # ユーザー情報も一緒に返す (必要に応じて)
            likes_count: post.likes.count,
            is_liked_by_current_user: current_user&.likes&.exists?(post_id: post.id)
          )
        end
        render json: @posts
      end

      def show
        render json: @post.as_json(include: :user).merge( # ユーザー情報も一緒に返す
          likes_count: @post.likes.count,
          is_liked_by_current_user: current_user&.likes&.exists?(post_id: @post.id)
        )
      end

      def create
        @post = current_user.posts.new(post_params) # current_userに関連付けて投稿を作成
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
        head :no_content # 204 No Content - 削除成功時にボディを返さない
      end

      private

      def set_post
        @post = Post.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: '投稿が見つかりません' }, status: :not_found
      end

      def post_params
        params.require(:post).permit(:content, :post_type, :media_url) # user_id は current_user から取得
      end
    end
  end
end