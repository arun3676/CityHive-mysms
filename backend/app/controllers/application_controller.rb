# Base controller for the API. Every endpoint requires a logged-in user unless
# it explicitly opts out (see AuthController and the Twilio webhook).
# current_user / authenticate_user! / sign_in / sign_out come from Devise.
class ApplicationController < ActionController::API
  before_action :authenticate_user!
end
