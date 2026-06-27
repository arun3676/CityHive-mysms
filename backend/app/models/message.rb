# A single SMS, persisted in MongoDB via Mongoid. Owned by a User (Bonus 1).
class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :to, type: String
  field :from, type: String
  # Delivery lifecycle: queued / sent / delivered / undelivered / failed.
  field :status, type: String, default: "queued"
  field :twilio_sid, type: String
  # Twilio error code if delivery failed (e.g. "30032"), set via the webhook.
  field :error_code, type: String
  # Owner of the message — messages are scoped per user.
  field :user_id, type: BSON::ObjectId

  validates :body, presence: true
  validates :to, presence: true

  # Most-recent-first is the natural order for a message list.
  default_scope -> { order(created_at: :desc) }

  # Clean JSON for the API: expose a string `id`, hide internal user_id.
  def as_json(*)
    {
      id: id.to_s,
      to: to,
      from: from,
      body: body,
      status: status,
      twilio_sid: twilio_sid,
      error_code: error_code,
      created_at: created_at
    }
  end
end
