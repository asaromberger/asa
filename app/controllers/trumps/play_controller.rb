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
		newsetup()
	end

	def create
		newsetup()
		board = TrumpsBoard.new
		board.trumps_game_id = @gameid
		board.round = @round
		board.numberofcards = number_of_cards(@players.count, @round)
		if board.numberofcards < 0
			fail
		end
		made = 0
		failure = 0
		@players.each do |player|
			@names[player.id] = TrumpsName.find(player.trumps_name_id).name
			@bid[player.id] = params["bid#{player.id}"]
			if @bid[player.id] == ""
				failure = 1
			end
			@made[player.id] = params["made#{player.id}"]
			if @made[player.id] == ""
				failure = 1
			end
		end
		if failure > 0
			@alert = "Scores are incomplete"
			render :new
			return
		end
		board.save
		made = 0
		TrumpsPlayer.where("trumps_game_id = ?", @gameid).each do |player|
			score = TrumpsScore.new
			score.trumps_game_id = @gameid
			score.trumps_board_id = board.id
			score.trumps_player_id = player.id
			score.bid = @bid[player.id]
			score.made = @made[player.id]
			made += score.made
			score.save
		end
		if made != number_of_cards(@players.count, @round)
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{board.round} Has wrong number of tricks made"
		else
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{board.round} Added"
		end
	end

	def edit
		editsetup()
		@cards = number_of_cards(@names.count, @round)
		@title = "Round: #{@round}, #{@cards} Cards"
		TrumpsScore.where("trumps_game_id = ? AND trumps_board_id = ?", @gameid, @board.id).each do |score|
			@bid[score.trumps_player_id] = score.bid
			@made[score.trumps_player_id] = score.made
		end
	end

	def update
		if editsetup() > 0
			@alert = "Scores are incomplete"
			render :edit
			return
		end
		made = 0
		@players.each do |player|
			score = TrumpsScore.where("trumps_game_id = ? AND trumps_board_id = ? AND trumps_player_id = ?", @gameid, @board.id, player.id).first
			score.trumps_game_id = @gameid
			score.trumps_board_id = @board.id
			score.trumps_player_id = player.id
			score.bid = params["bid#{player.id}"]
			score.made = params["made#{player.id}"]
			made += score.made
			score.save
		end
		if made != number_of_cards(@players.count, @round)
			# @alert = "Board #{board.round} has wrong number of tricks made"
			# render :edit
			redirect_to trumps_play_index_path(game: @gameid), alert: "Board #{@board.round} Has wrong number of tricks made"
		else
			redirect_to trumps_play_index_path(game: @gameid), notice: "Board #{@board.round} Updated"
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
			redirect_to trumps_play_index_path(game: @game_id), alert: "Cannot handle #{nplayers} Players"
			fail
			return(-1)
		end
	end

	def newsetup
		@gameid = params[:game].to_i
		@players = TrumpsPlayer.where("trumps_game_id = ?", @gameid).order('porder')
		@names = Hash.new
		@players.each do |player|
			name = TrumpsName.find(player.trumps_name_id)
			@names[player.id] = name.name
		end
		@maxboard = TrumpsBoard.where("trumps_game_id = ?", @gameid).order('round DESC').first
		if @maxboard
			@round = @maxboard.round + 1
		else
			@round = 1
		end
		@cards = number_of_cards(@names.count, @round)
		if ! @cards
			redirect_to trumps_play_index_path(game: @gameid), notice: "No more boards"
			return
		end
		@title = "Game: #{@gameid} Round: #{@round}, #{@cards} Cards"
		@scores = Hash.new
		@bid = Hash.new
		@made = Hash.new
		@names.each do |id, name|
			@scores[id] = 0
			@bid[id] = ""
			@made[id] = ""
		end
		TrumpsScore.where("trumps_game_id = ?", @gameid).order('trumps_board_id, trumps_player_id').each do |score|
			if score.bid == 0
				if score.made == 0
					@scores[score.trumps_player_id] += 10
				else
					@scores[score.trumps_player_id] -= score.made * 10
				end
			else
				if score.made < score.bid
					@scores[score.trumps_player_id] -= 10 * score.bid
				else
					@scores[score.trumps_player_id] += score.bid * 10 - (score.made - score.bid) * 10
				end
			end
		end
	end

	def editsetup
		@gameid = params[:game].to_i
		@players = TrumpsPlayer.where("trumps_game_id = ?", @gameid).order('porder')
		@round = params[:round].to_i
		@board = TrumpsBoard.where("trumps_game_id = ? AND round = ?", @gameid, @round).first
		if ! @board
			fail
		end
		@names = Hash.new
		@bid = Hash.new
		@made = Hash.new
		failure = 0
		@players.each do |player|
			@names[player.id] = TrumpsName.find(player.trumps_name_id).name
			@bid[player.id] = params["bid#{player.id}"]
			if params["bid#{player.id}"] == ""
				failure = 1
			end
			@made[player.id] = params["made#{player.id}"]
			if params["made#{player.id}"] == ""
				failure = 1
			end
		end
		return(failure)
	end

end
