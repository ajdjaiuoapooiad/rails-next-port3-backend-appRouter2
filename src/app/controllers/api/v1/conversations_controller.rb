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
            recipient = User.find(recipient_id) # собеседника находим
            current_user_data = {
              id: current_user.id,
              username: current_user.username,
              display_name: current_user.profile&.display_name,
              user_icon_url: current_user.profile&.user_icon&.attached? ? url_for(current_user.profile.user_icon) : nil
            }
            recipient_data = {
              id: recipient.id,
              username: recipient.username,
              display_name: recipient.profile&.display_name,
              user_icon_url: recipient.profile&.user_icon&.attached? ? url_for(recipient.profile.user_icon) : nil
            }
            render json: {
              id: @conversation.id,
              participants: [current_user_data, recipient_data],
              last_message: @conversation.messages.last&.content,
              last_message_at: @conversation.messages.last&.created_at
            }
          else
            render json: [] # 空のレスポンスを返す
          end
        else
          @conversations = current_user.conversations.includes(:users, :messages)
          render json: @conversations.map { |conversation|
            participants = conversation.users.map { |user|
              {
                id: user.id,
                username: user.username,
                display_name: user.profile&.display_name,
                user_icon_url: user.profile&.user_icon&.attached? ? url_for(user.profile.user_icon) : nil
              }
            }
            {
              id: conversation.id,
              participants: participants,
              last_message: conversation.messages.last&.content,
              last_message_at: conversation.messages.last&.created_at
            }
          }
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found if params[:user_id].present?
      end

      def show
        # ここで会話に参加しているユーザーの情報を取得し、user_icon_urlを含める
        participants = @conversation.users.map { |user|
          {
            id: user.id,
            username: user.username,
            display_name: user.profile&.display_name, # сюда добавил display_name
            user_icon_url: user.profile&.user_icon&.attached? ? url_for(user.profile.user_icon) : nil, # вот это добавил
          }
        }
        render json: @conversation.as_json(include: { messages: { include: :user } }).merge({ participants: participants }) # и вот это
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
