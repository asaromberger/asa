class PasswordResetsController < ApplicationController
	before_action :require_signed_in

	def edit
		@title = "Reset Your Password"
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update(user_params)
			flash[:notice] = "Password updated"
			sign_in @user
			redirect_to users_path
		else
			render 'edit'
		end
	end

	private

	def user_params
		params.require(:user).permit(:password, :password_confirmation)
	end

end
