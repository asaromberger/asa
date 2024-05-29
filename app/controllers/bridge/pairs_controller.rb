class Bridge::PairsController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Players'
		@date = params[:date].to_date
		@stype = params[:stype]
		@players = BridgePlayer.all.order('name')
		if @stype
			@players = BridgePlayer.all.order('name')
			@npairs = BridgeTable.where("stype = ?", @stype).order('stable DESC').first.stable * 2
			@pairs = Hash.new
			(1..@npairs).each do |pair|
				@pairs[pair] = ['', '']
			end
			BridgePair.where("date = ?", @date).each do |pair|
				@pairs[pair.pair] = [pair.player1_id, pair.player2_id]
			end
		else
			redirect_to bridge_results_path(date: @date, stype: @stype), alert: "No Type specified"
		end
	end

	def create
		@date = params[:date].to_date
		@stype = params[:stype]
		BridgePair.where("date = ?", @date).delete_all
		params[:table].each do |pair, values|
puts("pair: #{pair} date: #{@date}")
			pairs = BridgePair.where("date = ? AND pair = ?", @date, pair.to_i).first
puts("Result #{pairs.to_json}")
			if ! pairs
				pairs = BridgePair.new
				pairs.date = @date
				pairs.pair = pair.to_i
puts("New pairs for #{pair}")
			end
			if values["0"] && values["0"].to_i > 0
				pairs.player1_id = values["0"].to_i
			end
			if values["1"] && values["1"].to_i > 0
				pairs.player2_id = values["1"].to_i
			end
puts("Setup #{pair} [#{pairs.player1_id}] [#{pairs.player2_id}]")
			pairs.save
		end
		redirect_to bridge_pairs_path(date: @date, stype: @stype), notice: "Updated"
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEPLAYERS"
		end
	end

end
