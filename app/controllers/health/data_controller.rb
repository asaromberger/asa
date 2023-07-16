class Health::DataController < ApplicationController

	before_action :require_signed_in
	before_action :require_health

	def index
		@title = "Data"
		@data = HealthDatum.where("user_id = ?", current_user.id).order('date DESC')
		if params[:export]
			content = "Date,Resistance,Aerobic Calories (x10),Weight (x10),Steps,Flights,Miles (x100), Active Calories (x1000), Resting Calories (x1000)\n"
			@data = @data.sort_by { |data| data.date}
			@data.each do |data|
				content = "#{content}#{data.date},#{data.resistance},#{data.aerobic_calories},#{data.weight},#{data.steps},#{data.flights},#{data.miles},#{data.active_calories},#{data.resting_calories}\n"
			end
			send_data(content, type: 'application/csv', filename: 'HealthData.csv', disposition: :inline)
		end
	end

	def new
		@title = "New Data"
		@data = HealthDatum.new
		@data.user_id = current_user.id
		if params[:date]
			olddata = HealthDatum.where("user_id = ? AND date = ?", current_user.id, params[:date].to_date).first
			if olddata
				@data = olddata
			end
			@data.date = params[:date]
		else
			@data.date = Time.now.to_date
		end
		if params[:resistance]
			@data.resistance = params[:resistance]
		else
			@data.resistance = 10
		end
	end

	def create
		checknull()
		@data = HealthDatum.new(data_params)
		@data.user_id = current_user.id
		@data.save
		redirect_to new_health_datum_path(id: 0, date: @data.date + 1.day, resistance: @data.resistance), notice: 'Data added'
	end

	def edit
		@title = "Edit Data"
		@data = HealthDatum.find(params[:id])
	end

	def update
		checknull()
		@cdata = HealthDatum.find(params[:id])
		@cdata.update(data_params)
		@data = HealthDatum.where("user_id = ? AND date = ?", current_user.id, @cdata.date + 1.day).first
		if @data
			redirect_to edit_health_datum_path(id: @data.id), notice: 'Data updated'
		else
			@data = HealthDatum.new
			@data.user_id = current_user.id
			@data.date = @cdata.date + 1.day
			@data.resistance = @cdata.resistance
			redirect_to new_health_datum_path(id: 0, date: @data.date, resistance: @data.resistance), notice: 'Data updated'
		end
	end

	def destroy
		@data = HealthDatum.find(params[:id]).delete
		redirect_to health_data_path, notice: 'Data deleted'
	end

	private

	def require_health
		unless current_user_role('health')
			redirect_to users_path, alert: "Inadequate permissions: HEALTHDATA"
		end
	end

	def data_params
		params.require(:health_datum).permit(:date, :resistance, :aerobic_calories, :weight, :steps, :flights, :miles, :active_calories, :resting_calories)
	end

	def checknull
		if params[:health_datum][:resistance].blank?
			params[:health_datum][:resistance] = 0
		end
	end

end
