class Bridge::ResultsController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = "Bridge Scoring"
		@stype = params[:stype]
		@stypes = BridgeTable.all.pluck('DISTINCT stype')
		if ! params[:date]
			@date = Time.now.to_date
		else
			@date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
		end
		if params[:board]
			@board = params[:board]
		else
			@board = 1
		end
		if @stype
			@results = Hash.new
			BridgeTable.where("stype = ? AND board = ?", @stype, @board).order('round').each do |table|
				result = BridgeResult.where("date = ? AND board = ? AND ns = ? AND ew = ?", @date, @board, table.ns, table.ew).first
				if ! result
					result = BridgeResult.new
					result.date = @date
					result.board = @board
					result.ns = table.ns
					result.ew = table.ew
					result.save
				end
				@results[result.id] = result
			end
		end
	end

	def create
		date = params[:date].to_date
		stype = params[:stype]
		board = params[:board]
		params[:contract].each do |id, value|
			result = BridgeResult.find(id.to_i)
			result.contract = params[:contract][id]
			result.by = params[:by][id]
			result.result = params[:result][id]
			result.nsscore = params[:nsscore][id]
			result.ewscore = params[:ewscore][id]
			result.save
		end
		redirect_to bridge_results_path(date: { year: date.year, month: date.month, day: date.day}, stype: stype, board: board.to_i + 1)
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
