module Api
  module V1
    class NotificationsController < ApplicationController
      before_action :set_notification, only: [:show, :update, :destroy]

      def index
        @notifications = Notification.all
        render json: @notifications
      end

      def show
        render json: @notification
      end

      def create
        @notification = Notification.new(notification_params)
        if @notification.save
          render json: @notification, status: :created
        else
          render json: @notification.errors, status: :unprocessable_entity
        end
      end

      def update
        if @notification.update(notification_params)
          render json: @notification
        else
          render json: @notification.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @notification.destroy
        render json: { message: 'Notification deleted successfully' }
      end

      private

      def set_notification
        @notification = Notification.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Notification not found' }, status: :not_found
      end

      def notification_params
        params.require(:notification).permit(:recipient_id, :sender_id, :notifiable_type, :notifiable_id, :notification_type, :read_at)
      end
    end
  end 
end
