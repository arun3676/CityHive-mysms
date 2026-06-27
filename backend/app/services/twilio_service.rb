# Thin wrapper around the Twilio REST client.
#
# Authenticates with the Account SID + Auth Token. (A restricted API key is the
# more locked-down option and was tried first, but this account's API key did
# not authenticate — likely a mistyped secret, which Twilio only shows once. The
# auth token works reliably. To switch back later, create a fresh API key and
# pass ENV["TWILIO_API_KEY_SID"], ENV["TWILIO_API_KEY_SECRET"], account_sid.)
class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN")
    )
  end

  # Sends an SMS. Returns the Twilio message resource (responds to #sid, #status).
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
    # Only attach the delivery-status webhook if one is configured (empty locally).
    callback = ENV["TWILIO_STATUS_CALLBACK_URL"]
    params[:status_callback] = callback if callback.present?
    params
  end
end
