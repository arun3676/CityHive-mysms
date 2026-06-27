class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Authenticate by username + password (per the spec), not email.
  devise :database_authenticatable, :registerable, authentication_keys: [:username]

  field :username,           type: String
  field :encrypted_password, type: String, default: ""

  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
  # Devise hashes the raw password into encrypted_password; validate the raw one.
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  index({ username: 1 }, { unique: true })

  private

  def password_required?
    new_record? || password.present?
  end
end
