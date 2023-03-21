class Health::HomeController < ApplicationController

	before_action :require_signed_in, except: [:new, :create]
	before_action :require_health

	# landing page
	def index
		@title = 'Health Home'
	end

	private
      
	def require_health
		unless current_user_role('health')
			redirect_to users_path, alert: "Inadequate permission: Health"
		end
	end

end
