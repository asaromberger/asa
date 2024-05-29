class Bridge::TablesController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = "Bridge Tables"
		@tables = Hash.new
		# tables[stype][table][round]
		BridgeTable.all.order('stype, stable, round, board').each do |xtable|
			if ! @tables[xtable.stype]
				@tables[xtable.stype] = Hash.new
			end
			if ! @tables[xtable.stype][xtable.stable]
				@tables[xtable.stype][xtable.stable] = Hash.new
			end
			if ! @tables[xtable.stype][xtable.stable][xtable.round]
				@tables[xtable.stype][xtable.stable][xtable.round] = Hash.new
			end
			if ! @tables[xtable.stype][xtable.stable][xtable.round]
				@tables[xtable.stype][xtable.stable][xtable.round] = Hash.new
			end
			if ! @tables[xtable.stype][xtable.stable][xtable.round][xtable.board]
				@tables[xtable.stype][xtable.stable][xtable.round][xtable.board] = Hash.new
			end
			@tables[xtable.stype][xtable.stable][xtable.round][xtable.board] = xtable
		end
	end

	# create/edit a date
	def new
		@title = "New Entry"
		@what = BridgeTable.new
	end

	def create
		@what = BridgeTable.new(table_params)
		if @what.save
			redirect_to bridge_tables_path, notice: "Entry added"
		else
			redirect_to bridge_tables_path, alert: "Failed to add entry"
		end
	end

	def edit
		@title = "Update Entry"
		@what = BridgeTable.find(params[:id])
	end

	def update
		@what = BridgeTable.find(params[:id])
		if @what.update(table_params)
			redirect_to bridge_tables_path, notice: "Entry updated"
		else
			redirect_to bridge_tables_path, alert: "Failed to update entry"
		end
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

	def table_params
		params.require(:bridge_table).permit(:stype, :stable, :round, :ns, :ew, :board)
	end
end
