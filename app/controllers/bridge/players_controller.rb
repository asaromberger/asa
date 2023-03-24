class Bridge::PlayersController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Players'
		@players = BridgePlayer.all.order('name')
	end

	# create a new player
	def new
		@player = BridgePlayer.new
		@date = params[:date]
	end

	def create
		name = params[:bridge_player][:name]
		@player = BridgePlayer.where("name = ?", name)
		if @player.count > 0
			redirect_to scores_path, alert: "Player #{name} Already Exists"
		else
			@player = BridgePlayer.new
			@player.name = name
			@player.save
				redirect_to new_score_path(date: params[:date], back: 'back'), notice: "Player #{name} Added"
		end
	end

	# edit player
	def edit
		@player = BridgePlayer.find(params[:id])
	end

	def update
		name = params[:bridge_player][:name]
		@player = BridgePlayer.find(params[:id])
		@player.name = name
		@player.save
		redirect_to scores_path, notice: "Player #{name} Updated"
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
