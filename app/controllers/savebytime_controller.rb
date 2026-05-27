class SavebytimeController < ApplicationController
	before_action :require_signed_in
	before_action :require_siteadmin

	def edit
		@title = "SaveByTime"
		@savebytime = Permission.where("pkey = 'savebytime'").first
		if ! @savebytime
			@savebytime = Permission.new
			@savebytime.user_id = current_user.id
			@savebytime.pkey = 'savebytime';
			@savebytime.pvalue = {key0: "0"}
			@savebytime.save
		end
	end

	def update
		@savebytime = Permission.where("pkey = 'savebytime'").first
		@savebytime.update(savebytime_params)
		@savebytime.save
		time = Time.now.strftime("%H:%M:%S")
		respond_to do |format|
			format.html {
				redirect_to edit_savebytime_path(0), notice: "Saved"
			}
			format.js {
				render json: {"message": "Saved: #{time}"}, status: :accepted
			}
		end
	end

	private

	def require_siteadmin
		unless current_user_role('siteadmin')
			redirect_to users_path, alert: "Inadequate permissions: ROLES"
		end
	end

	def savebytime_params
		params.require(:permission).permit(pvalue: params[:permission][:pvalue].try(:keys))
	end

end
