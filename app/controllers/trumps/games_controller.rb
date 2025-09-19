class Trumps::GamesController < ApplicationController

	before_action :require_signed_in
	before_action :require_trumps

	# list
	# create a new game
	def new
		@title = "New Game"
		@game = TrumpsGame.new
		@names = TrumpsName.all.order('name')
	end

	def create
		@game = TrumpsGame.new
		@game.date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
		if ! @game.save
			redirect_to trumps_play_index_path alert: "Game failed to create"
		end
		TrumpsName.all.each do |name|
			if params["player#{name.id.to_s}"]
				player = TrumpsPlayer.new
				player.trumps_game_id = @game.id
				player.trumps_name_id = name.id
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
