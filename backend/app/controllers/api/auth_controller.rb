module Api
  # Username/password auth backed by Devise (session cookie based).
  class AuthController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[signup login logout me], raise: false

    # POST /api/signup  { user: { username, password } }
    def signup
      user = User.new(auth_params)
      if user.save
        sign_in(user)
        render json: { user: user_json(user) }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_content
      end
    end

    # POST /api/login  { user: { username, password } }
    def login
      user = User.find_for_database_authentication(username: auth_params[:username])
      if user&.valid_password?(auth_params[:password])
        sign_in(user)
        render json: { user: user_json(user) }
      else
        render json: { errors: ["Invalid username or password"] }, status: :unauthorized
      end
    end

    # DELETE /api/logout
    def logout
      sign_out(current_user) if user_signed_in?
      head :no_content
    end

    # GET /api/me — who am I? (null if not logged in)
    def me
      render json: { user: current_user ? user_json(current_user) : nil }
    end

    private

    def auth_params
      params.require(:user).permit(:username, :password)
    end

    def user_json(user)
      { id: user.id.to_s, username: user.username }
    end
  end
end
