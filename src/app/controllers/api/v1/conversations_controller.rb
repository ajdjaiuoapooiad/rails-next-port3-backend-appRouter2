module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :authorize_request
      before_action :set_conversation, only: [:show]

      def index
        if params[:user_id].present?
          recipient_id = params[:user_id].to_i
          current_user_id = current_user.id

          # 1. ログインユーザーが参加している会話を絞り込む
          conversations = current_user.conversations

          # 2. それらの会話から、指定された受信者との1対1の会話を検索する
          @conversation = conversations.joins(:users)
                                      .where(users: { id: recipient_id })
                                      .first

          if @conversation
            # 修正：current_user_data, recipient_data の取得方法を修正
            participants = @conversation.users.to_a # usersを配列に変換
            current_user_data = participants.find { |user| user.id == current_user_id }
            recipient_data = participants.find { |user| user.id == recipient_id }

            # ユーザーデータが存在する場合のみ、user_icon_url を取得
            current_user_data_with_details = {
              id: current_user_data&.id, # nilチェック
              username: current_user_data&.username, # nilチェック
              display_name: current_user_data&.profile&.display_name,
              user_icon_url: current_user_data&.profile&.user_icon&.attached? ? url_for(current_user.profile.user_icon) : nil
            }
            recipient_data_with_details = {
              id: recipient_data&.id, # nilチェック
              username: recipient_data&.username, # nilチェック
              display_name: recipient_data&.profile&.display_name,
              user_icon_url: recipient_data&.profile&.user_icon&.attached? ? url_for(recipient_data.profile.user_icon) : nil
            }

            render json: {
              id: @conversation.id,
              participants: [current_user_data_with_details, recipient_data_with_details],
              last_message: @conversation.messages.last&.content,
              last_message_at: @conversation.messages.last&.created_at
            }
          else
            render json: [] # 会話がない場合は空の配列を返す
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
        participants = @conversation.users.map { |user|
          {
            id: user.id,
            username: user.username,
            display_name: user.profile&.display_name,
            user_icon_url: user.profile&.user_icon&.attached? ? url_for(user.profile.user_icon) : nil,
          }
        }
        render json: @conversation.as_json(include: { messages: { include: :user } }).merge({ participants: participants })
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
