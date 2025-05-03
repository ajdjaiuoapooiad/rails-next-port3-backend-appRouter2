# app/controllers/api/v1/likes_controller.rb
module Api
  module V1
    class LikesController < ApplicationController
      before_action :authorize_request

      def create
        @like = current_user.likes.new(like_params)
        if @like.save
          # いいね！された投稿の作成者が自分自身ではない場合に通知を作成
          unless @like.post.user_id == current_user.id
            Notification.create(
              recipient_id: @like.post.user_id, # 投稿の作成者のID
              sender_id: current_user.id,       # いいね！したユーザーのID
              notifiable: @like.post,           # 通知対象を投稿自身に設定
              notification_type: 'like'
            )
          end
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