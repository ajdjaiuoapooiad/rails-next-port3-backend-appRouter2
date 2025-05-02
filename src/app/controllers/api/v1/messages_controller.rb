# app/controllers/api/v1/messages_controller.rb
module Api
  module V1
    class MessagesController < ApplicationController
      before_action :authorize_request
      before_action :set_conversation, only: [:index, :create]
      before_action :set_message, only: [:show, :update, :destroy]
      before_action :authorize_message!, only: [:show, :update, :destroy] # メッセージの操作権限を確認

      def index
        @messages = @conversation.messages.order(created_at: :asc).includes(:user)
        render json: @messages.map { |message|
          message.as_json.merge(user: { id: message.user.id, username: message.user.username })
        }
      end

      def show
        render json: @message.as_json.merge(user: { id: @message.user.id, username: @message.user.username })
      end

      def create
        @message = @conversation.messages.new(content: params[:content], user: current_user)
        if @message.save
          render json: @message, status: :created
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      def update
        if @message.update(content: params[:content])
          render json: @message
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @message.destroy
        render json: { message: 'Message deleted successfully' }
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:conversation_id])
        unless @conversation.users.include?(current_user)
          render json: { error: 'Not authorized to access this conversation' }, status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Conversation not found' }, status: :not_found
      end

      def set_message
        @message = Message.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Message not found' }, status: :not_found
      end

      def authorize_message!
        unless @message.conversation.users.include?(current_user)
          render json: { error: 'Not authorized to manage this message' }, status: :forbidden
        end
      end
    end
  end
end