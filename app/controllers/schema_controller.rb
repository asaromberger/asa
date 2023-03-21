class SchemaController < ApplicationController

	before_action :require_signed_in
	before_action :require_siteadmin

	def index
		@title = 'Schema'
		@tables = Hash.new
		ActiveRecord::Base.connection.tables.sort.each do |table|
			if table != 'ar_internal_metadata' && table != 'schema_migrations' && table != 'delayed_jobs'
			  if table == 'team_stats'
				# constantize maps to TeamStat rather than TeamStats
				@table = TeamStats.columns
			  else
				@table = table.classify.constantize.columns
			  end
			  @tables[table] = Hash.new
			  @tables[table] = @table
			end
		end
	end

	private
      
	def user_params
		params.require(:user).permit(:email, :password, :password_confirmation)
	end

	def require_siteadmin
		if ! current_user_role('siteadmin')
			redirect_to new_session_path, alert: "Insufficient permission: SCHEMA"
		end
	end

end

