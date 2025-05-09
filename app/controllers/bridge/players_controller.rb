class Bridge::PlayersController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Players'
		@players = BridgePlayer.all.order('name')
		@times = params[:times]
	end

	# create a new player
	def new
		@player = BridgePlayer.new
		@times = params[:times]
		@date = params[:date]
		start_end_date()
		if (params[:player])
			@playertag = true
		end
	end

	def create
		start_end_date()
		name = params[:bridge_player][:name]
		email = params[:bridge_player][:email]
		@player = BridgePlayer.where("name = ?", name)
		@times = params[:times]
		if @player.count > 0
			if params[:player]
				redirect_to bridge_players_path(start_date: @start_date, end_date: @end_date, times: @times), alert: "Player #{name} Already Exists"
			else
				redirect_to bridge_scores_path(start_date: @start_date, end_date: @end_date, times: @times), alert: "Player #{name} Already Exists"
			end
		else
			@player = BridgePlayer.new
			@player.name = name
			@player.email = email
			@player.save
			if params[:playertag]
				redirect_to bridge_players_path(date: params[:date], back: 'back', start_date: @start_date, end_date: @end_date, times: @times), notice: "Player #{name} Added"
			else
				redirect_to new_bridge_score_path(date: params[:date], back: 'back', start_date: @start_date, end_date: @end_date, times: @times), notice: "Player #{name} Added"
			end
		end
	end

	# edit player
	def edit
		@player = BridgePlayer.find(params[:id])
		@times = params[:times]
		start_end_date()
	end

	def update
		start_end_date()
		name = params[:bridge_player][:name]
		email = params[:bridge_player][:email]
		@player = BridgePlayer.find(params[:id])
		@times = params[:times]
		@player.name = name
		@player.email = email
		@player.save
		redirect_to bridge_players_path(start_date: @start_date, end_date: @end_date, times: @times), notice: "Player #{name} Updated"
	end

	def destroy
		@player = BridgePlayer.find(params[:id])
		if BridgeScore.where("bridge_player_id = ?", @player.id).count > 0
			redirect_to bridge_players_path(start_date: @start_date, end_date: @end_date, times: @times), notice: "Player #{@player.name} is in use"
		else
			@player.delete
			redirect_to bridge_players_path(start_date: @start_date, end_date: @end_date, times: @times), notice: "Player #{@player.name} deleted"
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
