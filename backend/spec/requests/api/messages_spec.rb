require "rails_helper"

RSpec.describe "Api::Messages", type: :request do
  let(:twilio_result) { double("twilio", sid: "SM999", status: "queued") }

  before do
    allow_any_instance_of(TwilioService).to receive(:send_sms).and_return(twilio_result)
    User.create!(username: "alice", password: "password123")
    post "/api/login", params: { user: { username: "alice", password: "password123" } }
  end

  describe "POST /api/messages" do
    it "sends via Twilio and persists the message for the current user" do
      expect {
        post "/api/messages", params: { message: { to: "+15551234567", body: "Hello" } }
      }.to change(Message, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["to"]).to eq("+15551234567")
      expect(json["twilio_sid"]).to eq("SM999")
      expect(json["id"]).to be_present
    end

    it "returns 422 and does not call Twilio when body is missing" do
      expect_any_instance_of(TwilioService).not_to receive(:send_sms)
      post "/api/messages", params: { message: { to: "+15551234567" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(Message.count).to eq(0)
    end

    it "records the message as failed when Twilio raises" do
      allow_any_instance_of(TwilioService).to receive(:send_sms)
        .and_raise(Twilio::REST::TwilioError.new("Twilio is down"))
      post "/api/messages", params: { message: { to: "+15551234567", body: "Hi" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(Message.last.status).to eq("failed")
    end
  end

  describe "GET /api/messages" do
    it "returns the current user's messages, newest first" do
      post "/api/messages", params: { message: { to: "+15551110000", body: "first" } }
      post "/api/messages", params: { message: { to: "+15551110000", body: "second" } }

      get "/api/messages"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).map { |m| m["body"] }).to eq(["second", "first"])
    end

    it "does not leak messages belonging to other users" do
      other = User.create!(username: "bob", password: "password123")
      Message.create!(to: "+15559998888", body: "not yours", user_id: other.id)

      get "/api/messages"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end
  end

  describe "authentication" do
    it "rejects unauthenticated access with 401" do
      delete "/api/logout"
      get "/api/messages"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/messages/status_callback" do
    it "updates status by MessageSid even when logged out" do
      delete "/api/logout"
      msg = Message.create!(to: "+1", body: "x", twilio_sid: "SMcb",
                            status: "queued", user_id: BSON::ObjectId.new)

      post "/api/messages/status_callback",
           params: { MessageSid: "SMcb", MessageStatus: "delivered" }

      expect(response).to have_http_status(:no_content)
      expect(msg.reload.status).to eq("delivered")
    end
  end
end
