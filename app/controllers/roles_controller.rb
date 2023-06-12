class RolesController < ApplicationController
	before_action :require_signed_in
	before_action :require_siteadmin

	def index
		@title = "Roles"
		@users = User.all.order('email')
	end

	def edit
		@title = "Edit Roles"
		@user = User.find(params[:id])
		@roles = all_roles()
	end

	def update
		@user = User.find(params[:id])
		@roles = all_roles()
		@roles.each do |role|
			perms = Permission.where("user_id = ? AND pkey = ?", @user.id, role)
			if params[role] == 'on'
				if perms.count == 0
					perm = Permission.new
					perm.user_id = @user.id
					perm.pkey = role
					perm.save
				end
			else
				if perms.count > 0
					perms.delete_all
				end
			end
		end
		redirect_to roles_path, notice: "Permissions Updated for #{@user.email}"
	end

	private

	def all_roles
		return(['siteadmin', 'health', 'bridge', 'music', 'genealogy', 'genealogy_admin', 'finance_payments', 'finance_expenses', 'finance_investments', 'finance_admin'])
	end

	def require_siteadmin
		unless current_user_role('siteadmin')
			redirect_to users_path, alert: "Inadequate permissions: ROLES"
		end
	end

end
