class UsersController < ApplicationController

	before_action :require_signed_in, except: [:new, :create]

	# landing page
	def index
		@title = 'Home page'
	end

	# create a new user
	def new
		@user = User.new
	end

	def create
		email = params['user']['email'].downcase.gsub(/^\s+/, '').gsub(/\s+$/, '')
		@user = User.find_by(email: email)
		if @user
			if @user.update(user_password)
				redirect_to users_path, notice: "Password updated for #{@user.email}"
			else
				redirect_to users_path, alert: "Password did not match"
			end
		else
			@user = User.new(user_params)
			if @user.save
				redirect_to users_path, notice: "Account created for #{@user.email}"
			else
				render 'new'
			end
		end
	end

	private
      
	def user_params
		params.require(:user).permit(:email, :password, :password_confirmation)
	end

	def user_password
		params.require(:user).permit(:password, :password_confirmation)
	end

end
