class Bridge::ScoresController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Scores'
		@scores = Hash.new
		today = Time.now.to_date
		if params[:end_date]
			@end_date = params[:end_date].to_date
		else
			@end_date = today
		end
		if params[:start_date]
			@start_date = params[:start_date].to_date
		else
			@start_date = @end_date - (13 * 7 - 1).days
		end
		@date_list = []
		date = BridgeScore.all.order('date').first
		if date
			date = date.date
		else
			date = Time.now.to_date
		end
		while(date <= today)
			@date_list.push(date)
			date += 7.days
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
		@rating = @rating.sort_by { |pid, score| -score }
		i = 0
		@rating.each do |pid, score|
			i += 1
			@right[pid]['rank'] = i
		end
	end

	# create/edit a date
	def new
		@title = 'Session'
		@players = BridgePlayer.all.order('name')
		if params[:date]
			@date = params[:date].to_date
		else
			@date = Time.now.to_date
		end
		@scores = Hash.new
		BridgeScore.where("date = ?", @date).each do |score|
			@scores[score.bridge_player_id] = score.score
		end
	end

	def create
		@date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i)
		scores = Hash.new
		BridgeScore.where("date = ?", @date).each do |score|
			scores[score.bridge_player_id] = score
		end
		BridgePlayer.all.each do |player|
			if params[:score][player.id.to_s]
				if ! scores[player.id]
					scores[player.id] = BridgeScore.new
					scores[player.id].date = @date
					scores[player.id].bridge_player_id = player.id
				end
				scores[player.id].score = params[:score][player.id.to_s].to_f
				scores[player.id].save
			else
				scores[player.id].delete
			end
		end
		redirect_to bridge_scores_path, notice: "Scores updated for #{@date}"
	end

	def date
		@date = params[:date].to_date
		@title = "Scores for #{@date}"
		@scores = Hash.new
		BridgeScore.where("date = ?", @date).each do |score|
			if score.score && score.score > 0
				@scores[score.bridge_player_id] = Hash.new
				@scores[score.bridge_player_id]['score'] = score.score
				@scores[score.bridge_player_id]['name'] = BridgePlayer.find(score.bridge_player_id).name
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
		@bottom = Hash.new
		@bottom['players'] = players
		@bottom['score'] = total_score
	end

	def player
		@player = BridgePlayer.find(params[:id].to_i)
		@title = "Scores for #{@player.name}"
		@scores = Hash.new
		@dates = Hash.new
		bridge_player_ids = BridgeScore.all.pluck('DISTINCT bridge_player_id')
		BridgePlayer.where("id IN (?)", bridge_player_ids).order('name').each do |player|
			@scores[player.id] = Hash.new
			@scores[player.id]['name'] = player.name
			@scores[player.id]['score'] = Hash.new
			@scores[player.id]['percent'] = Hash.new
		end
		BridgeScore.all.each do |score|
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
		content = "Date, Player, Score\n"
		BridgeScore.joins(:bridge_player).all.order('date, name').each do |score|
			if ! score.score.blank? && score.score > 0
				content = "#{content}#{score.date},#{players[score.bridge_player_id]},#{score.score}\n"
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

end