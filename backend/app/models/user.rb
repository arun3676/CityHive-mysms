class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :registerable, authentication_keys: [:username]

  field :username,           type: String
  field :encrypted_password, type: String, default: ""

  validates :username, presence: true, uniqueness: true, length: { minimum: 3 }
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  index({ username: 1 }, { unique: true })

  private

  def password_required?
    new_record? || password.present?
  end
end
