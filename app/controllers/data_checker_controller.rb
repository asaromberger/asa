class DataCheckerController < ApplicationController
	before_action :require_signed_in
	before_action :require_siteadmin

	def index
		@title = "Data Checker"
		@tables = Hash.new
		tables = ActiveRecord::Base.connection.tables.sort
		tables.each do |table|
			next if table == 'ar_internal_metadata'
			next if table == 'schema_migrations'
			tableref = table.classify.constantize
			tablename = tableref.name
			table_columns = tableref.columns
			@tables[tablename] = Hash.new
			@tables[tablename]['ref'] = tableref
			@tables[tablename]['columns'] = table_columns
			@tables[tablename]['ids'] = tableref.all.order('id').pluck('id')
		end
		@tables.each do |name, table|
			tableref = table['ref']
			@tables[name]['xrefs'] = []
			@tables[name]['errors'] = []
			table['columns'].each do |column|
				col = column.name
				if col.match('_id$')
					xrefname = col.gsub(/_id$/, '')
					xref = xrefname.classify.constantize
					@tables[name]['errors'].push("References: #{xref.name}")
					tableref.where("#{col} NOT IN (?)", @tables[xref.name]['ids']).each do |t|
						@tables[name]['errors'].push("#{name}[#{t.id}]:#{col} = ${t.col} MISSING")
					end
				end
			end
			# show pkey values
			if name == 'Permission'
				Permission.all.order('pkey').pluck('DISTINCT pkey').each do |pkey|
					@tables[name]['errors'].push("pkey: #{pkey}")
				end
			end
		end
	end

	private

	def require_siteadmin
		if ! current_user_role('siteadmin')
			redirect_to users_path, alert: "Insufficient permission: DATA CHECKER"
		end
	end

end
