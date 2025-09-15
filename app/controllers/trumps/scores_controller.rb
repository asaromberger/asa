class Trumps::ScoresController < ApplicationController

	before_action :require_signed_in
	before_action :require_bridge

	# list
	def index
		@title = 'Scores'
		start_end_date()
		@date_list = TrumpsGame.all.order('date').pluck('DISTINCT date')
		@games = Hash.new
		TrumpsGame.all.each do |game|
			@games[game.id]['date'] = game.date
		end
	end

	# create/edit a date
	def new
	fail
	end

	def create
	fail
	end

	def date
	fail
	end

	def player
	fail
	end

	def scores_export
	fail
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
