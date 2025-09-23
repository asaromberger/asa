class Trumps::PlayController < ApplicationController

	before_action :require_signed_in
	before_action :require_trumps

	def index
		@gameid = params[:game].to_i
		@date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
		@title = "#{@date} Game #{@gameid}"
		@names = Hash.new
		tscores = Hash.new
		TrumpsPlayer.where("trumps_game_id = ?", @gameid).order('porder').each do |player|
			name = TrumpsName.find(player.trumps_name_id)
			@names[player.id] = name.name
			tscores[player.id] = 0
		end
		@scores = Hash.new
		TrumpsBoard.where("trumps_game_id = ?", @gameid).order('round').each do |board|
			@scores[board.round] = Hash.new
			@scores[board.round]['cards'] = board.numberofcards
			@names.each do |id, name|
				@scores[board.round][id] = Hash.new
				@scores[board.round][id]['bid'] = -1
				@scores[board.round][id]['made'] = -1
				@scores[board.round][id]['score'] = 0
			end
		end
		TrumpsScore.where("trumps_game_id = ?", @gameid).each do |score|
			round = TrumpsBoard.find(score.trumps_board_id).round
			@scores[round][score.trumps_player_id]['bid'] = score.bid
			@scores[round][score.trumps_player_id]['made'] = score.made
			if score.bid == score.made
				@scores[round][score.trumps_player_id]['delta'] = nil
			else
				@scores[round][score.trumps_player_id]['delta'] = score.bid - score.made
			end
		end
		@scores.each do |round, values|
			@names.each do |id, name|
				bid = @scores[round][id]['bid']
				made = @scores[round][id]['made']
				if bid == 0
					if made == 0
						tscores[id] += 10
					else
						tscores[id] -= made * 10
					end
				else
					if made < bid
						tscores[id] -= 10 * bid
					else
						tscores[id] += bid * 10 - (made - bid) * 10
					end
				end
				@scores[round][id]['score'] = tscores[id]
			end
		end
		@alerts = Hash.new
		@scores.each do |round, values|
			made = 0
			@names.each do |nid, name|
				made += values[nid]['made']
			end
			if made != number_of_cards(@names.count, round)
				@alerts[round] = true
			end
		end
	end

	def new
		@gameid = params[:game].to_i
		@names = Hash.new
		TrumpsPlayer.where("trumps_game_id = ?", @gameid).order('porder').each do |player|
			name = TrumpsName.find(player.trumps_name_id)
			@names[player.id] = name.name
		end
		maxboard = TrumpsBoard.where("trumps_game_id = ?", @gameid).order('round DESC').first
		if maxboard
			round = maxboard.round + 1
		else
			round = 1
		end
		@cards = number_of_cards(@names.count, round)
		if ! @cards
			redirect_to trumps_play_index_path(game: @gameid), notice: "No more boards"
			return
		end
		@title = "Round: #{round}, #{@cards} Cards"
	end

	def create
		@gameid = params[:game].to_i
		maxboard = TrumpsBoard.where("trumps_game_id = ?", @gameid).order('round DESC').first
		if maxboard
			round = maxboard.round + 1
		else
			round = 1
		end
		nplayers = TrumpsPlayer.where("trumps_game_id = ?", @gameid).pluck('trumps_name_id').count
		board = TrumpsBoard.new
		board.trumps_game_id = @gameid
		board.round = round
		board.numberofcards = number_of_cards(nplayers, round)
		board.save
		made = 0
		TrumpsPlayer.where("trumps_game_id = ?", @gameid).each do |player|
			score = TrumpsScore.new
			score.trumps_game_id = @gameid
			score.trumps_board_id = board.id
			score.trumps_player_id = player.id
			score.bid = params["bid#{player.id}"]
			score.made = params["made#{player.id}"]
			made += score.made
			score.save
		end
		if made != number_of_cards(nplayers, round)
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{board.round} Has wrong number of tricks made"
		else
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{board.round} Added"
		end
	end

	def edit
		@gameid = params[:game].to_i
		@names = Hash.new
		TrumpsPlayer.where("trumps_game_id = ?", @gameid).order('porder').each do |player|
			name = TrumpsName.find(player.trumps_name_id)
			@names[player.id] = name.name
		end
		@round = params[:id].to_i
		board = TrumpsBoard.where("trumps_game_id = ? AND round = ?", @gameid, @round).first
		@cards = number_of_cards(@names.count, @round)
		@title = "Round: #{@round}, #{@cards} Cards"
		@bid = Hash.new
		@made = Hash.new
		TrumpsScore.where("trumps_game_id = ? AND trumps_board_id = ?", @gameid, board.id).each do |score|
			@bid[score.trumps_player_id] = score.bid
			@made[score.trumps_player_id] = score.made
		end
	end

	def update
		@gameid = params[:game].to_i
		round = params[:round].to_i
		board = TrumpsBoard.where("trumps_game_id = ? AND round = ?", @gameid, round).first
		made = 0
		nplayers = 0
		TrumpsPlayer.where("trumps_game_id = ?", @gameid).each do |player|
			score = TrumpsScore.new
			score.trumps_game_id = @gameid
			score.trumps_board_id = board.id
			score.trumps_player_id = player.id
			score.bid = params["bid#{player.id}"]
			score.made = params["made#{player.id}"]
			made += score.made
			nplayers += 1
			score.save
		end
		if made != number_of_cards(nplayers, round)
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{board.round} Has wrong number of tricks made"
		else
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{board.round} Updated"
		end
	end

private

	def require_trumps
		unless current_user_role('trumps')
			redirect_to users_path, alert: "Inadequate permissions: TRUMPSPLAYERS"
		end
	end

	def number_of_cards(nplayers, round)
		if nplayers == 3 || nplayers == 4
			return([0, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12][round])
		elsif nplayers == 5
			return([0, 10, 9, 8, 7, 6, 5, 4, 3, 3, 4, 5, 6, 7, 8, 9, 10][round])
		elsif nplayers == 6
			return([0, 8, 7, 6, 5, 4, 3, 3, 4, 5, 6, 7, 8][round])
		else
			redirect_to trunps_play_index_path(game: @game_id), alert: "Cannot handle #{nplayers} Players"
		end
	end

end
