class SessionsController < ApplicationController

  before_action :require_signed_in, except: [:new, :create]

  def new
  	@title = "Sign in"
  end

  def create
	email = to_email(params[:session][:email])
    user = User.find_by(email: email)
    if user && user.authenticate(params[:session][:password])
      sign_in user
	  redirect_to users_path, notice: "Welcome"
    else
      redirect_to new_session_path, alert: "Invalid email/password combination"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
