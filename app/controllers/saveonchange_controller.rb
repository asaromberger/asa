class SaveonchangeController < ApplicationController
	before_action :require_signed_in
	before_action :require_siteadmin

	def edit
		@title = "Save On Change"
		@saveonchange = Permission.where("pkey = 'saveonchange'").first
		if ! @saveonchange
			@saveonchange = Permission.new
			@saveonchange.user_id = current_user.id
			@saveonchange.pkey = 'saveonchange';
			@saveonchange.pvalue = {key0: "0"}
			@saveonchange.save
		end
	end

	def update
		@saveonchange = Permission.where("pkey = 'saveonchange'").first
		@saveonchange.update(saveonchange_params)
		@saveonchange.save
		time = Time.now.strftime("%H:%M:%S")
		respond_to do |format|
			format.html {
				redirect_to edit_saveonchange_path(0), notice: "Saved"
				puts("XXXXXX HTML")
			}
			format.js {
				render json: {"message": "Saved: #{time}"}, status: :accepted
				puts("XXXXXX JSON")
			}
		end
	end

	private

	def require_siteadmin
		unless current_user_role('siteadmin')
			redirect_to users_path, alert: "Inadequate permissions: ROLES"
		end
	end

	def saveonchange_params
		params.require(:permission).permit(pvalue: params[:permission][:pvalue].try(:keys))
	end

end
