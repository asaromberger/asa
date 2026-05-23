class AutosaveController < ApplicationController
	before_action :require_signed_in
	before_action :require_siteadmin

	def edit
		@title = "Autosave"
		@autosave = Permission.where("pkey = 'autosave'").first
		if ! @autosave
			@autosave = Permission.new
			@autosave.user_id = current_user.id
			@autosave.pkey = 'autosave';
			@autosave.pvalue = {key0: "0"}
		end
	end

	def update
		@autosave = Permission.where("pkey = 'autosave'").first
		@autosave.update(autosave_params)
		@autosave.save
		time = Time.now.strftime("%H:%M:%S")
		respond_to do |format|
			format.html {
				redirect_to edit_autosave_path(0), notice: "Saved"
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

	def autosave_params
		params.require(:permission).permit(pvalue: params[:permission][:pvalue].try(:keys))
	end

end
