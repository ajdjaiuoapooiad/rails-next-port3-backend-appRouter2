module Api
  module V1
    class CommentsController < ApplicationController
      before_action :authorize_request
      before_action :set_post, only: [:index, :create]
      before_action :set_comment, only: [:destroy]
      before_action :authorize_comment_owner, only: [:destroy]

      def index
        @comments = @post.comments.order(created_at: :asc).map do |comment|
          user = comment.user
          user_icon_url = user.profile&.user_icon&.attached? ? url_for(user.profile.user_icon) : nil
          comment.as_json(include: :user).merge(
            user_icon_url: user_icon_url,
            display_name: user.display_name.present? ? user.display_name : user.username
          )
        end
        render json: @comments
      end

      def create
        @comment = @post.comments.new(user: current_user, content: comment_params[:content])
        if @comment.save
          render json: @comment, status: :created
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        head :no_content # 204 No Content
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Post not found' }, status: :not_found
      end

      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Comment not found' }, status: :not_found
      end

      def comment_params
        params.require(:comment).permit(:content) # post_id はパスから取得
      end

      def authorize_comment_owner
        unless @comment.user == current_user
          render json: { error: 'You are not authorized to delete this comment.' }, status: :forbidden
        end
      end
    end
  end
end