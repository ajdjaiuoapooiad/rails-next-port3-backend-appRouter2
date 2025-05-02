module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :set_conversation, only: [:show, :destroy]

      def index
        @conversations = Conversation.all
        render json: @conversations
      end

      def show
        render json: @conversation
      end

      def create
        @conversation = Conversation.new(conversation_params)
        if @conversation.save
          render json: @conversation, status: :created
        else
          render json: @conversation.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @conversation.destroy
        render json: { message: 'Conversation deleted successfully' }
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Conversation not found' }, status: :not_found
      end

      def conversation_params
        params.require(:conversation).permit() # 必要に応じて許可する属性を追加
      end
    end
  end
end
