class Bridge::BbosController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@types = BridgeBboType.all.order('btype')
		if params[:type]
			@type = params[:type]
		else
			@type = @types[0].id
		end
		@types.each do |type|
			if type.id == @type.to_i
				@typename = type.btype
			end
		end
		@games = BridgeBbo.where("bridge_bbo_type_id = ?", @type).order('date')
		@results = Hash.new
		@results['points'] = 0
		@results['score'] = 0
		@ranks = []
		(1..6).each do |rank|
		@ranks[rank] = 0
		end
		@games.each do |game|
			if game.points
				@results['points'] += game.points
			end
			@results['score'] += game.score
			@ranks[game.rank] += 1
		end
		@results['score'] /= @games.count
	end

	# create a game
	def new
		@title = 'New Score'
		@type = params[:type]
		@score = BridgeBbo.new
		@score.bridge_bbo_type_id = @type
		@score.date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
		@types = BridgeBboType.all.order('btype')
	end

	def create
		@score = BridgeBbo.new(bbo_params)
		if @score.save
			redirect_to bridge_bbos_path(type: params[:type]), notice: "Score added"
		else
			redirect_to bridge_bbos_path(type: params[:type]), alert: "Failed to add item"
		end
	end

	# edit a game
	def edit
		@title = 'New Score'
		@score = BridgeBbo.find(params[:id])
		@type = params[:type]
		@types = BridgeBboType.all.order('btype')
	end

	def update
		@score = BridgeBbo.find(params[:id])
		if @score.update(bbo_params)
			redirect_to bridge_bbos_path(type: params[:type]), notice: "Score updated"
		else
			redirect_to bridge_bbos_path(type: params[:type]), alert: "Failed to update item"
		end
	end

	def destroy
		@score = BridgeBbo.find(params[:id])
		@score.delete
		redirect_to bridge_bbos_path(type: params[:type]), notice: "#{@score.date} removed"
	end

private

	def require_bridge
		unless current_user_role('bridge')
			redirect_to users_path, alert: "Inadequate permissions: BRIDGEBBOS"
		end
	end

	def bbo_params
		params.require(:bridge_bbo).permit(:date, :bridge_bbo_type_id, :bbo_id, :score, :rank, :points)
	end

end
