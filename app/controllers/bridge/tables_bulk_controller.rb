class Bridge::TablesBulkController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	require 'csv'

	# list
	def new
		@title = "Bridge Tables Bulk Input"
	end

	# create/edit a date
	def create
		stype = params[:stype]
		BridgeTable.where("stype = ?", stype).delete_all
		document = params[:document]
		if document.blank? || document.original_filename.blank?
			redirect_to new_bridge_tables_bulk_path, alert: "No spreadsheet specified"
			return
		end
		input = File.open(document.tempfile, 'rb').read.gsub(/[\r\n]+/, "\n")
		lines = CSV.parse(input)
		table = -1
		round = -1
		ns = -1
		ew = -1
		board = -1
		lines.each do |line|
puts(line.to_json)
			if table < 0
				(0..line.count-1).each do |i|
					t = line[i].downcase
					if t == 'table'
						table = i
					elsif t == 'round'
						round = i
					elsif t == 'n/s'
						ns = i
					elsif t == 'e/w'
						ew = i
					elsif t == 'board'
						board = i
					end
				end
				if table < 0
					
					redirect_to new_bridge_tables_bulk_path, alert: "no Table header"
					return
				end
				if round < 0
					
					redirect_to new_bridge_tables_bulk_path, alert: "no Round header"
					return
				end
				if ns < 0
					
					redirect_to new_bridge_tables_bulk_path, alert: "no N/S header"
					return
				end
				if ew < 0
					
					redirect_to new_bridge_tables_bulk_path, alert: "no E/W header"
					return
				end
				if board < 0
					
					redirect_to new_bridge_tables_bulk_path, alert: "no Board header"
					return
				end
				next
			end
			ttable = BridgeTable.new
			ttable.stype = stype
			ttable.stable = line[table]
			ttable.round = line[round]
			ttable.ns = line[ns]
			ttable.ew = line[ew]
			ttable.board = line[board]
			ttable.save
		end
		redirect_to bridge_tables_path, notice: "New Type #{stype} created"
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
