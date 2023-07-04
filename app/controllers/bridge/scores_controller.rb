class Bridge::ScoresController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Scores'
		@scores = Hash.new
		start_end_date()
		@timeslist = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
		if params[:times]
			@times = params[:times].to_i
		else
			@times = 1
		end
		@date_list = []
		dates = BridgeScore.all.order('date').pluck('DISTINCT date')
		if dates.count > 0
			date = dates[dates.count - 1]
		else
			date = Time.now.to_date
		end
		dates.each do |d|
			@date_list.push(d)
		end
		@dates = Hash.new
		bridge_player_ids = BridgeScore.all.pluck('DISTINCT bridge_player_id')
		BridgePlayer.where("id IN (?)", bridge_player_ids).order('name').each do |player|
			@scores[player.id] = Hash.new
			@scores[player.id]['name'] = player.name
			@scores[player.id]['score'] = Hash.new
			@scores[player.id]['percent'] = Hash.new
		end
		BridgeScore.where("date >= ? AND date <= ?", @start_date, @end_date).each do |score|
			if score.score > 0
				@dates[score.date] = true
				@scores[score.bridge_player_id]['score'][score.date] = score.score
			end
		end
		@dates = @dates.sort_by { |date, value| date}
		@bottom = Hash.new
		@dates.each do |date, value|
			total_score = 0
			players = 0
			@scores.each do |pid, values|
				if values['score'][date]
					total_score += values['score'][date]
					players += 1
				end
			end
			max_score = total_score * 2 / players
			@scores.each do |pid, values|
				if values['score'][date]
					values['percent'][date] = values['score'][date] * 100 / max_score
				end
			end
			@bottom[date] = Hash.new
			@bottom[date]['players'] = players
			@bottom[date]['score'] = total_score
		end
		@right = Hash.new
		@rating = Hash.new
		@scores.each do |pid, values|
			@right[pid] = Hash.new
			@right[pid]['percent'] = 0
			@right[pid]['times'] = 0
			@dates.each do |date, value|
				if values['percent'][date]
					@right[pid]['percent'] += values['percent'][date]
					@right[pid]['times'] += 1
				end
			end
			if @right[pid]['times'] == 0
				@right[pid]['percent'] = 0
				@rating[pid] = 0
			else
				@right[pid]['percent'] /= @right[pid]['times']
				@rating[pid] = @right[pid]['percent']
			end
		end
		@scores.each do |pid, values|
			if @right[pid]['times'] < @times
				@scores.delete(pid)
				@rating.delete(pid)
			end
		end
		@rating = @rating.sort_by { |pid, score| -score }
		i = 0
		@rating.each do |pid, score|
			i += 1
			@right[pid]['rank'] = i
		end
	end

	# create/edit a date
	def new
		@players = BridgePlayer.all.order('name')
		start_end_date()
		if params[:date]
			@date = params[:date].to_date
		else
			@date = Time.now.to_date
		end
		@times = params[:times]
		@title = "Session #{@date}"
		@scores = Hash.new
		@pairs = Hash.new
		BridgeScore.where("date = ?", @date).each do |score|
			@scores[score.bridge_player_id] = score.score
			@pairs[score.bridge_player_id] = score.pair
		end
	end

	def create
		@orig_date = params[:orig_date].to_date
		@times = params[:times]
		@date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
		start_end_date()
		scores = Hash.new
		BridgeScore.where("date = ?", @orig_date).each do |score|
			scores[score.bridge_player_id] = score
		end
		BridgePlayer.all.each do |player|
			if params[:score][player.id.to_s] && params[:score][player.id.to_s].to_f > 0.0
				if ! scores[player.id]
					scores[player.id] = BridgeScore.new
					scores[player.id].bridge_player_id = player.id
				end
				scores[player.id].date = @date
				scores[player.id].score = params[:score][player.id.to_s].to_f
				scores[player.id].pair = params[:pair][player.id.to_s].to_i
				scores[player.id].save
			else
				if scores[player.id]
					scores[player.id].delete
				end
			end
		end
		redirect_to bridge_score_date_path(date: @date, start_date: @start_date, end_date: @end_date, times: @times), notice: "Scores updated for #{@date}"
	end

	def date
		@date = params[:date].to_date
		@times = params[:times]
		start_end_date()
		@title = "Scores for #{@date}"
		@scores = Hash.new
		BridgeScore.where("date = ?", @date).each do |score|
			if score.score && score.score > 0
				@scores[score.bridge_player_id] = Hash.new
				@scores[score.bridge_player_id]['score'] = score.score
				player = BridgePlayer.find(score.bridge_player_id)
				@scores[score.bridge_player_id]['name'] = player.name
				@scores[score.bridge_player_id]['pair'] = score.pair
			end
		end
		players = @scores.count
		total_score = 0
		@scores.each do |pid, values|
			total_score += values['score']
		end
		max_score = total_score * 2 / players
		@scores.each do |pid, values|
			values['percent'] = values['score'] * 100 / max_score
		end
		# @scores = @scores.sort_by { |pid, values| values['name'].downcase }
		@scores = @scores.sort_by { |pid, values| [-values['score'], values['pair'], values['name'].downcase] }
		@bottom = Hash.new
		@bottom['players'] = players
		@bottom['score'] = total_score
	end

	def player
		@player = BridgePlayer.find(params[:id].to_i)
		@times = params[:times]
		@title = "Scores for #{@player.name}"
		start_end_date()
		@scores = Hash.new
		@dates = Hash.new
		bridge_player_ids = BridgeScore.all.pluck('DISTINCT bridge_player_id')
		BridgePlayer.where("id IN (?)", bridge_player_ids).order('name').each do |player|
			@scores[player.id] = Hash.new
			@scores[player.id]['name'] = player.name
			@scores[player.id]['score'] = Hash.new
			@scores[player.id]['percent'] = Hash.new
		end
		BridgeScore.where("date >= ? and date <= ?", @start_date, @end_date).each do |score|
			if score.score > 0
				@dates[score.date] = true
				@scores[score.bridge_player_id]['score'][score.date] = score.score
			end
		end
		@dates = @dates.sort_by { |date, value| date}
		@dates.each do |date, value|
			total_score = 0
			players = 0
			@scores.each do |pid, values|
				if values['score'][date]
					total_score += values['score'][date]
					players += 1
				end
			end
			max_score = total_score * 2 / players
			@scores.each do |pid, values|
				if values['score'][date]
					values['percent'][date] = values['score'][date] * 100 / max_score
				end
			end
		end
		@right = Hash.new
		@rating = Hash.new
		@scores.each do |pid, values|
			@right[pid] = Hash.new
			@right[pid]['percent'] = 0
			@right[pid]['times'] = 0
			@dates.each do |date, value|
				if values['percent'][date]
					@right[pid]['percent'] += values['percent'][date]
					@right[pid]['times'] += 1
				end
			end
			if @right[pid]['times'] == 0
				@right[pid]['percent'] = 0
				@rating[pid] = 0
			else
				@right[pid]['percent'] /= @right[pid]['times']
				@rating[pid] = @right[pid]['percent']
			end
		end
		@rating = @rating.sort_by { |pid, score| -score }
		i = 0
		@rating.each do |pid, score|
			i += 1
			@right[pid]['rank'] = i
		end
	end

	def scores_export
		players = Hash.new
		BridgePlayer.all.each do |player|
			players[player.id] = player.name
		end
		content = "Date,Player,Score,Pair\n"
		BridgeScore.joins(:bridge_player).all.order('date, name').each do |score|
			if ! score.score.blank? && score.score > 0
				content = "#{content}#{score.date},#{players[score.bridge_player_id]},#{score.score},#{score.pair}\n"
			end
		end
		send_data(content, type: 'application/csv', filename: 'Scores.csv', disposition: :inline)
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

	def start_end_date
		@today = Time.now.to_date
		if params[:end_date]
			@end_date = params[:end_date].to_date
		else
			@end_date = @today
		end
		if params[:start_date]
			@start_date = params[:start_date].to_date
		else
			@start_date = @end_date - (13 * 7 - 1).days
		end
	end

end
