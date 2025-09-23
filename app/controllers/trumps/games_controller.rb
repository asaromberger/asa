class Trumps::GamesController < ApplicationController

	before_action :require_signed_in
	before_action :require_trumps

	# list
	# create a new game
	def new
		@title = "New Game"
		@game = TrumpsGame.new
		@names = TrumpsName.all.order('name')
		@players = Hash.new
		@players[1] = 0
		@players[2] = 0
		@players[3] = 0
		@players[4] = 0
		@players[5] = 0
		@players[6] = 0
	end

	def create
		@game = TrumpsGame.new
		@game.date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
		if ! @game.save
			redirect_to trumps_play_index_path alert: "Game failed to create"
		end
		params['players'].each do |order, id|
			order = order.to_i
			id = id.to_i
			if id > 0
				name = TrumpsName.find(id)
				player = TrumpsPlayer.new
				player.trumps_game_id = @game.id
				player.trumps_name_id = name.id
				player.porder = order
				player.save
			end
		end
		redirect_to trumps_play_index_path(game: @game.id)
	end

private

	def require_trumps
		unless current_user_role('trumps')
			redirect_to users_path, alert: "Inadequate permissions: TRUMPSPLAYERS"
		end
	end

end
