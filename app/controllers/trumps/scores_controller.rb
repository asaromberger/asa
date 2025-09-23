class Trumps::ScoresController < ApplicationController

	before_action :require_signed_in
	before_action :require_trumps

	# list
	def index
		@title = 'Scores'
		start_end_date()
		@date_list = TrumpsGame.all.order('date').pluck('DISTINCT date')
		@names = Hash.new
		TrumpsName.all.order('name').each do |name|
			@names[name.id] = Hash.new
			@names[name.id]['name'] = name.name
			@names[name.id]['games'] = Hash.new
		end
		@games = Hash.new
		TrumpsGame.all.order('id').each do |game|
			@games[game.id] = game.date
		end
		TrumpsScore.all.each do |score|
			if score.bid == 0
				if score.made == 0
					t = 10
				else
					t = -score.made * 10
				end
			else
				if score.made < score.bid
					t = -10 * score.bid
				else
					t = score.bid * 10 - (score.made - score.bid) * 10
				end
			end
			nameid = TrumpsPlayer.find(score.trumps_player_id).trumps_name_id
			if ! @names[nameid]['games'][score.trumps_game_id]
				@names[nameid]['games'][score.trumps_game_id] = Hash.new
				@names[nameid]['games'][score.trumps_game_id]['score'] = 0
				@names[nameid]['games'][score.trumps_game_id]['rank'] = 0
			end
			@names[nameid]['games'][score.trumps_game_id]['score'] += t
		end
		@avgrank = Hash.new
		ngames = Hash.new
		@games.each do |gid, gvalues|
			t = Hash.new
			@names.each do |nid, nvalues|
				if nvalues['games'][gid]
					t[nid] = nvalues['games'][gid]['score']
				end
			end
			r = @names.count
			t.sort_by { |nid, score| score}.each do |nid, score|
				@names[nid]['games'][gid]['rank'] = r
				if ! @avgrank[nid]
					@avgrank[nid] = 0
					ngames[nid] = 0
				end
				@avgrank[nid] += r
				ngames[nid] += 1
				r -= 1
			end
		end
		@names.each do |nid, nvalues|
			@avgrank[nid] /= ngames[nid]
		end
	end

	def name
		redirect_to trumps_scores_path, alert: "Player summary not implemented"
	end

private

	def require_trumps
		unless current_user_role('trumps')
			redirect_to users_path, alert: "Inadequate permissions: TRUMPSPLAYERS"
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
