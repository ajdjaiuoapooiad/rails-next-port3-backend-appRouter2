module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authorize_request
      before_action :set_conversation, only: [:show]

      def index
        if params[:user_id].present?
          recipient_id = params[:user_id].to_i
          current_user_id = current_user.id

          @conversation = Conversation.joins(:users)
                                      .where(users: { id: [recipient_id] })
                                      .includes(:users, :messages)
                                      .first

          if @conversation
            render json: {
              id: @conversation.id,
              participants: @conversation.users.map { |user| { id: user.id, username: user.username } },
              last_message: @conversation.messages.last&.content,
              last_message_at: @conversation.messages.last&.created_at
            }
          else
            render json: [] # 空のレスポンスを返す
          end
        else
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
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found if params[:user_id].present?
      end

      def show
        render json: @conversation.as_json(include: { messages: { include: :user } })
      end

      def create
        recipient = User.find(params[:recipient_id])
        @conversation = Conversation.between(current_user.id, recipient.id).first_or_create
        ConversationUser.find_or_create_by(conversation: @conversation, user: current_user)
        ConversationUser.find_or_create_by(conversation: @conversation, user: recipient)
        render json: @conversation, status: :created
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