module Api
  module V1
    class MessagesController < ApplicationController
      before_action :set_message, only: [:show, :update, :destroy]

      def index
        @messages = Message.all
        render json: @messages
      end

      def show
        render json: @message
      end

      def create
        @message = Message.new(message_params)
        if @message.save
          render json: @message, status: :created
        else
          render json: @message.errors, status: :unprocessable_entity
        end
      end

      def update
        if @message.update(message_params)
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

      def set_message
        @message = Message.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Message not found' }, status: :not_found
      end

      def message_params
        params.require(:message).permit(:conversation_id, :user_id, :content)
      end
    end

  end 
end