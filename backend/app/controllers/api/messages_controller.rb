module Api
  class MessagesController < ApplicationController
    # The Twilio webhook is a server-to-server POST — no logged-in user.
    skip_before_action :authenticate_user!, only: :status_callback, raise: false
    before_action :verify_twilio_signature, only: :status_callback, if: -> { Rails.env.production? }

    # GET /api/messages — only the current user's messages.
    def index
      render json: Message.where(user_id: current_user.id).to_a
    end

    # POST /api/messages  { message: { to:, body: } }
    def create
      message = Message.new(
        message_params.to_h.merge(
          user_id: current_user.id,
          from: ENV["TWILIO_PHONE_NUMBER"]
        )
      )

      unless message.valid?
        return render json: { errors: message.errors.full_messages },
                      status: :unprocessable_content
      end

      begin
        result = TwilioService.new.send_sms(to: message.to, body: message.body)
        message.twilio_sid = result.sid
        message.status = result.status
        message.save!
        render json: message, status: :created
      rescue Twilio::REST::TwilioError => e
        message.status = "failed"
        message.save
        render json: { errors: [e.message] }, status: :unprocessable_content
      end
    end

    # POST /api/messages/status_callback  (Bonus 3) — Twilio delivery webhook.
    def status_callback
      message = Message.where(twilio_sid: params[:MessageSid]).first
      message&.update(
        status: params[:MessageStatus].presence || message.status,
        error_code: params[:ErrorCode]
      )
      head :no_content
    end

    private

    def message_params
      params.require(:message).permit(:to, :body)
    end

    def verify_twilio_signature
      validator = Twilio::Security::RequestValidator.new(ENV.fetch("TWILIO_AUTH_TOKEN"))
      signature = request.headers["X-Twilio-Signature"]
      url = ENV.fetch("TWILIO_STATUS_CALLBACK_URL", request.original_url)
      unless signature && validator.validate(url, request.request_parameters, signature)
        head :forbidden
      end
    end
  end
end
