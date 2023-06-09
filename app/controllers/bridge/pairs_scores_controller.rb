class Bridge::PairsScoresController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Pairs Scores'
		@scores = Hash.new
		start_end_date()
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
		@players = Hash.new
		BridgePlayer.all.each do |player|
			@players[player.id] = player.name
		end
		# collect results[date][pair]['players'] = list
		# collect results[date][pair]['soore'] = score
		results = Hash.new
		BridgeScore.where("date >= ? AND date <= ?", @start_date, @end_date).each do |score|
			if score.score > 0
				if results[score.date].blank?
					results[score.date] = Hash.new
					@dates[score.date] = 0
				end
				if results[score.date][score.pair].blank?
					results[score.date][score.pair] = Hash.new
					results[score.date][score.pair]['players'] = []
				end
				results[score.date][score.pair]['score'] = score.score
				results[score.date][score.pair]['players'].push(@players[score.bridge_player_id])
			end
		end
		# reorder list to prevent A & B AND B & A
		results.each do |date, pairs|
			pairs.each do |pair, values|
				values['players'] = values['players'].sort_by { |names| names.downcase }
			end
		end
		# collect @scores[pair][date]['score'] = score
		@scores = Hash.new
		results.each do |date, pairs|
			pairs.each do |pair, values|
				team = ""
				values['players'].each do |name|
					if team == ""
						team = name
					else
						team = "#{team} & #{name}"
					end
				end
				if @scores[team].blank?
					@scores[team] = Hash.new
				end
				if @scores[team][date].blank?
					@scores[team][date] = Hash.new
				end
				@scores[team][date]['score'] = values['score']
			end
		end
		# sort by pairs
		@scores = @scores.sort_by { |name, values| name.downcase }
		@dates = @dates.sort_by { |date, value| date }
		# date (column) totals
		@bottom = Hash.new
		@dates.each do |date, value|
			total_score = 0
			teams = 0
			@scores.each do |team, dates|
				if dates[date] && dates[date]['score'] && dates[date]['score'] > 0
					total_score += dates[date]['score']
					teams += 1
				end
			end
			max_score = total_score * 2 / teams
			@scores.each do |names, dates|
				if dates[date] && dates[date]['score']
					dates[date]['percent'] = dates[date]['score'] * 100 / max_score
				end
			end
			@bottom[date] = Hash.new
			@bottom[date]['players'] = teams
			@bottom[date]['score'] = total_score * 2
		end
		@right = Hash.new
		@rating = Hash.new
		@scores.each do |name, dates|
			@right[name] = Hash.new
			@right[name]['percent'] = 0
			@right[name]['times'] = 0
			dates.each do |date, values|
				if values['percent']
					@right[name]['percent'] += values['percent']
					@right[name]['times'] += 1
				end
			end
			if @right[name]['times'] == 0
				@right[name]['percent'] = 0
				@rating[name] = 0
			else
				@right[name]['percent'] /= @right[name]['times']
				@rating[name] = @right[name]['percent']
			end
		end
		@rating = @rating.sort_by { |name, score| -score }
		i = 0
		@rating.each do |pid, score|
			i += 1
			@right[pid]['rank'] = i
		end
		@scores.each do |name, dates|
			if @right[name]['times'] < @times
				@scores.delete(pid)
			end
		end
	end

	def date
		@date = params[:date].to_date
		start_end_date()
		@title = "Scores for #{@date}"
		scores = Hash.new
		names = Hash.new
		BridgeScore.where("date = ?", @date).each do |score|
			if score.score && score.score > 0
				scores[score.pair] = score.score
				if names[score.pair]
					names[score.pair] = "#{names[score.pair]} & #{BridgePlayer.find(score.bridge_player_id).name}"
				else
					names[score.pair] = BridgePlayer.find(score.bridge_player_id).name
				end
			end
		end
		@scores = Hash.new
		names.each do |pair, name|
			@scores[name] = Hash.new
			@scores[name]['score'] = scores[pair]
		end
		total_score = 0
		@scores.each do |name, values|
			total_score += values['score']
		end
		max_score = total_score * 2 / @scores.count
		@scores.each do |name, values|

			values['percent'] = values['score'] * 100 / max_score
		end
		# @scores = @scores.sort_by { |pid, values| values['name'].downcase }
		@scores = @scores.sort_by { |name, values| -values['score'] }
		@bottom = Hash.new
		@bottom['players'] = @scores.count
		@bottom['score'] = total_score * 2
	end

	def pair
		player1name = params[:id].sub(/ &.*/, '')
		player1 = BridgePlayer.where("name = ?", player1name).first
		player2name = params[:id].sub(/.*& /, '')
		player2 = BridgePlayer.where("name = ?", player2name).first
		@player = player1
		@team = params[:id]
		@title = "Scores for #{@team}"
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
