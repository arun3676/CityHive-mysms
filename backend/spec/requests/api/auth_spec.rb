require "rails_helper"

RSpec.describe "Api::Auth", type: :request do
  describe "POST /api/signup" do
    it "creates a user and logs them in" do
      expect {
        post "/api/signup", params: { user: { username: "newuser", password: "password123" } }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["user"]["username"]).to eq("newuser")
    end

    it "rejects a too-short password" do
      post "/api/signup", params: { user: { username: "newuser", password: "x" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "rejects a duplicate username" do
      User.create!(username: "dupe", password: "password123")
      post "/api/signup", params: { user: { username: "dupe", password: "password123" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /api/login" do
    before { User.create!(username: "alice", password: "password123") }

    it "logs in with valid credentials" do
      post "/api/login", params: { user: { username: "alice", password: "password123" } }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["user"]["username"]).to eq("alice")
    end

    it "rejects invalid credentials with 401" do
      post "/api/login", params: { user: { username: "alice", password: "wrong" } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/me" do
    it "returns null when logged out" do
      get "/api/me"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["user"]).to be_nil
    end

    it "returns the user after login" do
      User.create!(username: "alice", password: "password123")
      post "/api/login", params: { user: { username: "alice", password: "password123" } }
      get "/api/me"
      expect(JSON.parse(response.body)["user"]["username"]).to eq("alice")
    end
  end

  describe "DELETE /api/logout" do
    it "ends the session" do
      User.create!(username: "alice", password: "password123")
      post "/api/login", params: { user: { username: "alice", password: "password123" } }
      delete "/api/logout"
      expect(response).to have_http_status(:no_content)

      get "/api/me"
      expect(JSON.parse(response.body)["user"]).to be_nil
    end
  end
end
