class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :to, type: String
  field :from, type: String
  field :status, type: String, default: "queued"
  field :twilio_sid, type: String
  field :error_code, type: String
  field :user_id, type: BSON::ObjectId

  validates :body, presence: true
  validates :to, presence: true

  default_scope -> { order(created_at: :desc) }

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
