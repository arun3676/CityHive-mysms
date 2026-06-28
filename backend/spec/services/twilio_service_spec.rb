require "rails_helper"

RSpec.describe TwilioService do
  let(:messages_resource) { double("messages") }
  let(:client) { double("Twilio::REST::Client", messages: messages_resource) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(client)
  end

  it "authenticates with the account SID + auth token" do
    allow(messages_resource).to receive(:create).and_return(double(sid: "SM1", status: "queued"))

    described_class.new.send_sms(to: "+15551234567", body: "hi")

    expect(Twilio::REST::Client).to have_received(:new).with(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN")
    )
  end

  it "sends from the configured number and returns the Twilio result" do
    fake_result = double("message", sid: "SM123", status: "queued")
    expect(messages_resource).to receive(:create).with(
      hash_including(
        from: ENV.fetch("TWILIO_PHONE_NUMBER"),
        to: "+15551234567",
        body: "hi"
      )
    ).and_return(fake_result)

    result = described_class.new.send_sms(to: "+15551234567", body: "hi")

    expect(result.sid).to eq("SM123")
    expect(result.status).to eq("queued")
  end
end
