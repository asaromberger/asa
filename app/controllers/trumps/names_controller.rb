class Trumps::NamesController < ApplicationController

	before_action :require_signed_in
	before_action :require_trumps

	# list
	def index
		@title = 'Names'
		@names = TrumpsName.all.order('name')
		@times = params[:times]
	end

	# create a new name
	def new
		@name = TrumpsName.new
		@times = params[:times]
		@date = params[:date]
		start_end_date()
		if (params[:nametag])
			@nametag = true
		end
	end

	def create
		start_end_date()
		name = params[:trumps_name][:name]
		@name = TrumpsName.where("name = ?", name)
		@times = params[:times]
		if @name.count > 0
			if params[:name]
				redirect_to trumps_names_path(start_date: @start_date, end_date: @end_date, times: @times), alert: "Name #{name} Already Exists"
			else
				redirect_to trumps_scores_path(start_date: @start_date, end_date: @end_date, times: @times), alert: "Name #{name} Already Exists"
			end
		else
			@name = TrumpsName.new
			@name.name = name
			@name.save
			if params[:nametag]
				redirect_to trumps_names_path(date: params[:date], back: 'back', start_date: @start_date, end_date: @end_date, times: @times), notice: "Name #{name} Added"
			else
				redirect_to new_trumps_score_path(date: params[:date], back: 'back', start_date: @start_date, end_date: @end_date, times: @times), notice: "Name #{name} Added"
			end
		end
	end

	# edit name
	def edit
		@name = TrumpsName.find(params[:id])
		@times = params[:times]
		start_end_date()
	end

	def update
		start_end_date()
		name = params[:trumps_name][:name]
		@name = TrumpsName.find(params[:id])
		@times = params[:times]
		@name.name = name
		@name.save
		redirect_to trumps_names_path(start_date: @start_date, end_date: @end_date, times: @times), notice: "Name #{name} Updated"
	end

	def destroy
		@name = TrumpsName.find(params[:id])
		if TrumpsPlayer.where("trumps_name_id = ?", @name.id).count > 0
			redirect_to trumps_names_path(start_date: @start_date, end_date: @end_date, times: @times), notice: "Name #{@name.name} is in use"
		else
			@name.delete
			redirect_to trumps_names_path(start_date: @start_date, end_date: @end_date, times: @times), notice: "Name #{@name.name} deleted"
		end
	end

private

	def require_trumps
		unless current_user_role('trumps')
			redirect_to users_path, alert: "Inadequate permissions: TRUMPSPLAYERS"
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
