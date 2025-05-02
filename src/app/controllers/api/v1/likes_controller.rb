module Api
  module V1
    class LikesController < ApplicationController
      before_action :authorize_request

      def create
        @like = current_user.likes.new(like_params)
        if @like.save
          render json: @like, status: :created
        else
          render json: { errors: @like.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @like = current_user.likes.find_by(post_id: params[:like][:post_id])
        if @like
          @like.destroy
          head :no_content # 204 No Content - リクエストは成功したが、レスポンスボディは送信しない
        else
          render json: { error: 'いいねが見つかりません' }, status: :not_found
        end
      end

      private

      def like_params
        params.require(:like).permit(:post_id)
      end
    end
  end
end