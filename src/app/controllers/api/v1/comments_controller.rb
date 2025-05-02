module Api
  module V1
    class CommentsController < ApplicationController
      before_action :set_comment, only: [:destroy]

      def create
        @comment = Comment.new(comment_params)
        if @comment.save
          render json: @comment, status: :created
        else
          render json: @comment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        render json: { message: 'Comment deleted successfully' }
      end

      private

      def set_comment
        @comment = Comment.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Comment not found' }, status: :not_found
      end

      def comment_params
        params.require(:comment).permit(:user_id, :post_id, :content)
      end
    end
  end
end