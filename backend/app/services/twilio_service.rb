class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN")
    )
  end

  def send_sms(to:, body:)
    @client.messages.create(**message_params(to: to, body: body))
  end

  private

  def message_params(to:, body:)
    params = {
      from: ENV.fetch("TWILIO_PHONE_NUMBER"),
      to: to,
      body: body
    }
    callback = ENV["TWILIO_STATUS_CALLBACK_URL"]
    params[:status_callback] = callback if callback.present?
    params
  end
end
