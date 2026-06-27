require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with a username and password" do
    expect(User.new(username: "alice", password: "password123")).to be_valid
  end

  it "requires a username of at least 3 characters" do
    expect(User.new(username: "ab", password: "password123")).not_to be_valid
  end

  it "requires a password of at least 6 characters" do
    expect(User.new(username: "alice", password: "short")).not_to be_valid
  end

  it "rejects a duplicate username" do
    User.create!(username: "alice", password: "password123")
    expect(User.new(username: "alice", password: "password123")).not_to be_valid
  end

  it "authenticates the correct password and rejects a wrong one" do
    user = User.create!(username: "alice", password: "password123")
    expect(user.valid_password?("password123")).to be true
    expect(user.valid_password?("nope")).to be false
  end
end
