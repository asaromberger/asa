class UsersController < ApplicationController

	before_action :require_signed_in, except: [:new, :create]

	# landing page
	def index
		@user = current_user
		if params[:app_select]
			@user.application = params[:app_select]
			@user.save
			if @user.application == 'health'
				redirect_to health_data_path
			end
			if @user.application == 'bridge'
				redirect_to bridge_scores_path
			end
			if @user.application == 'music'
				redirect_to new_music_search_path
			end
			if @user.application == 'genealogy'
				redirect_to genealogy_search_index_path
			end
			if @user.application == 'finance'
				redirect_to finance_expenses_items_path
			end
		end
		@title = "Home page"
		apps = Hash.new
		valid_applications().each do |key, app|
			if Permission.where("user_id = ? AND pkey = ?", @user.id, key).count > 0
				apps[app] = key
			end
		end
		@applications = []
		apps.each do |app, key|
			@applications.push(app)
		end
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
