class Bridge::SummariesController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@dates = BridgeResult.all.order('date').pluck('DISTINCT date')
		if params[:date]
			@date = params[:date].to_date
		else
			@date = @dates[@dates.count - 1]
		end
		@title = "Results for #{@date}"
		@errors = 0
		@pairs = Hash.new
		BridgePair.where("date = ?", @date).order('pair').each do |pair|
			@pairs[pair.pair] = Hash.new
			if pair.player1_id && pair.player1_id > 0
				player1 = BridgePlayer.find(pair.player1_id).name
			else
				player1 = ""
			end
			if pair.player2_id && pair.player2_id > 0
				player2 = BridgePlayer.find(pair.player2_id).name
			else
				player2 = ""
			end
			@pairs[pair.pair]['pair'] = "#{player1}/#{player2}"
		end
		@boardscores = Hash.new	# boardscores[board][team]
		@totals = Hash.new
		(1..@pairs.count).each do |pair|
			@totals[pair] = 0
		end
		BridgeResult.where("date = ?", @date).each do |result|
			if ! @boardscores[result.board]
				@boardscores[result.board] = Hash.new
			end
			@boardscores[result.board][result.ns] = result.nspoints
			@boardscores[result.board][result.ew] = result.ewpoints
			if result.nspoints
				@totals[result.ns] += result.nspoints
			else
				@errors += 1
			end
			if result.ewpoints
				@totals[result.ew] += result.ewpoints
			else
				@errors += 1
			end
		end
		best = 0
		@boardscores[1].each do |pair, values|
			best += values
		end
		best = (best / @boardscores[1].count) * 2 * (@boardscores.count)
		@percent = Hash.new
		(1..@pairs.count).each do |pair|
			@percent[pair] = @totals[pair] / best
		end
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
