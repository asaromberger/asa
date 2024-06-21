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
		@pairs.each do |pair, data|
			data['total'] = 0
		end
		BridgeResult.where("date = ?", @date).each do |result|
			if ! @boardscores[result.board]
				@boardscores[result.board] = Hash.new
			end
			@boardscores[result.board][result.ns] = result.nspoints
			@boardscores[result.board][result.ew] = result.ewpoints
			if result.nspoints
				@pairs[result.ns]['total'] += result.nspoints
			else
				@errors += 1
			end
			if result.ewpoints
				@pairs[result.ew]['total'] += result.ewpoints
			else
				@errors += 1
			end
		end
		best = 0
		@boardscores[1].each do |pair, values|
			best += values
		end
		best = (best / @boardscores[1].count) * 2 * (@boardscores.count)
		@pairs.each do |pair, data|
			data['percent'] = @pairs[pair]['total'] / best
		end
		@pairs = @pairs.sort_by { |pair, data| -data['total']}
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
