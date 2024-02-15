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
		@games = BridgeBbo.where("bridge_bbo_type_id = ?", @type).order('date DESC')
		@results = Hash.new
		@results['points'] = 0
		@results['score'] = 0
		scoremax = 0
		scoremin = 1000
		ratingmax = 0
		ratingmin = 1000
		pointsmax = 0
		pointsmin = 1000
		@games.each do |game|
			if game.points
				@results['points'] += game.points
				if game.points > pointsmax
					pointsmax = game.points
				end
				if game.points < pointsmin
					pointsmin = game.points
				end
			end
			if game.score
				@results['score'] += game.score
				if game.score > scoremax
					scoremax = game.score
				end
				if game.score < scoremin
					scoremin = game.score
				end
			end
			if game.rank && game.rank > 0
				rating = (1 - (game.rank / game.no_players)) * 100
				if rating > ratingmax
					ratingmax = rating
				end
				if rating < ratingmin
					ratingmin = rating
				end
			end
		end
		@results['score'] /= @games.count
		scoredelta = (scoremax - scoremin) / 5.0
		@scorecoding = [
			[scoremin, 'bbo_color_1'],
			[scoremin + scoredelta, 'bbo_color_2'],
			[scoremin + 2 * scoredelta, 'bbo_color_3'],
			[scoremin + 3 * scoredelta, 'bbo_color_4'],
			[scoremin + 4 * scoredelta, 'bbo_color_5']
		]
		ratingdelta = (ratingmax - ratingmin) / 5.0
		@ratingcoding = [
			[ratingmin, 'bbo_color_1'],
			[ratingmin + ratingdelta, 'bbo_color_2'],
			[ratingmin + 2 * ratingdelta, 'bbo_color_3'],
			[ratingmin + 3 * ratingdelta, 'bbo_color_4'],
			[ratingmin + 4 * ratingdelta, 'bbo_color_5']
		]
		pointsdelta = (pointsmax - pointsmin) / 5.0
		@pointscoding = [
			[pointsmin, 'bbo_color_1'],
			[pointsmin + pointsdelta, 'bbo_color_2'],
			[pointsmin + 2 * pointsdelta, 'bbo_color_3'],
			[pointsmin + 3 * pointsdelta, 'bbo_color_4'],
			[pointsmin + 4 * pointsdelta, 'bbo_color_5']
		]
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
		params.require(:bridge_bbo).permit(:date, :bridge_bbo_type_id, :bbo_id, :score, :rank, :points, :no_players)
	end

end
