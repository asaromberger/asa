class Health::ImportController < ApplicationController

	before_action :require_signed_in
	before_action :require_health

	require 'csv'

	def new
		@title = "Import Data"
		@messages = []
		if params[:messages]
			params[:messages].sub(/\[/, '').sub(/\]$/, '').split(/,/).each do |message|
				@messages.push(message.gsub(/^"/, '').gsub(/"$/, ''))
			end
		end
	end

	def create
		@title = "Import Data"
		sheet = params[:sheet]
		if sheet.blank? || sheet.original_filename.blank?
			redirect_to new_health_import_path, alert: "No file selected"
		end
		data = CSV.open(sheet.tempfile, 'r')
		@messages = []
		@headers = Hash.new
		count_new = 0
		count_update = 0
		data.each do |line|
			if @headers.count == 0
				(0..line.count-1).each do |i|
					if line[i].match('Date')
						@headers['Date'] = i
					elsif line[i].match('Resistance')
						@headers['Resistance'] = i
					elsif line[i].match('Calories')
						@headers['Calories'] = i
					elsif line[i].match('Weight')
						@headers['Weight'] = i
					elsif line[i].match('Steps')
						@headers['Steps'] = i
					elsif line[i].match('Flights')
						@headers['Flights'] = i
					elsif line[i].match('Miles')
						@headers['Miles'] = i
					end
				end
				if ! @headers['Date']
					@messages.push("Input file requires a 'Date' column")
				end
				next
			else
				date = line[@headers['Date']].gsub(/^\s*/,'').gsub(/\s*/,'').to_date
				if @headers['Resistance']
					resistance = line[@headers['Resistance']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
				else
					resistance = nil
				end
				if @headers['Calories'] && line[@headers['Calories']]
					calories = line[@headers['Calories']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
				else
					calories = nil
				end
				if @headers['Weight'] && line[@headers['Weight']]
					weight = line[@headers['Weight']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
				else
					weight = nil
				end
				if @headers['Steps']
					steps = line[@headers['Steps']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
				else
					steps = nil
				end
				if @headers['Flights'] && line[@headers['Flights']]
					flights = line[@headers['Flights']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
				else
					flights = nil
				end
				if @headers['Miles']
					miles = line[@headers['Miles']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
				else
					miles = nil
				end
				if ! date.blank?
					data = HealthDatum.where("user_id = ? AND date = ?", current_user.id, date).first
					if ! data
						data = HealthDatum.new
						data.user_id = current_user.id
						data.date = date
						count_new += 1
					else
						count_update += 1
					end
					if resistance
						data.resistance = resistance
					end
					if calories
						data.calories = calories
					end
					if weight
						data.weight = weight
					end
					if steps
						data.steps = steps
					end
					if flights
						data.flights = flights
					end
					if miles
						data.miles = miles
					end
					data.save
				end
			end
		end
		@messages.push("#{count_new} records created");
		@messages.push("#{count_update} records updated");
		redirect_to new_health_import_path(messages: @messages.to_json)
	end

	private

	def require_health
		unless current_user_role('health')
			redirect_to users_path, alert: "Inadequate permissions: HEALTHIMPORT"
		end
	end

end
