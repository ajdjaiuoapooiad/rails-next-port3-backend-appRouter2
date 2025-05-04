module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authorize_request
      before_action :set_conversation, only: [:show]

      def index
        # 現在のユーザーが参加している会話の一覧を取得
        @conversations = current_user.conversations.includes(:users, :messages)
        render json: @conversations.map { |conversation|
          {
            id: conversation.id,
            participants: conversation.users.map { |user| { id: user.id, username: user.username } },
            last_message: conversation.messages.last&.content,
            last_message_at: conversation.messages.last&.created_at
          }
        }
      end

      def show
        render json: @conversation.as_json(include: { messages: { include: :user } })
      end

      def create
        # 新しい1対1の会話を作成 (例: recipient_id をパラメータで受け取る)
        recipient = User.find(params[:recipient_id])

        # 既存の会話を検索
        @conversation = Conversation.between(current_user.id, recipient.id).first

        if @conversation
          # 既存の会話が存在する場合、それを返す
          render json: @conversation, status: :ok
        else
          # 既存の会話がない場合のみ、新しい会話を作成
          @conversation = Conversation.new
          @conversation.users << current_user
          @conversation.users << recipient
          if @conversation.save
            render json: @conversation, status: :created
          else
            render json: { error: 'Failed to create conversation' }, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Recipient not found' }, status: :not_found
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:id])
        unless @conversation.users.include?(current_user)
          render json: { error: 'Not authorized to view this conversation' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Conversation not found' }, status: :not_found
      end
    end
  end
end
