class Health::ImportController < ApplicationController

	before_action :require_signed_in
	before_action :require_health

	require 'csv'

	def new
		@title = "Import Data"
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
		count = 0
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
				if @headers['Calories']
					calories = (line[@headers['Calories']].gsub(/^\s*/,'').gsub(/\s*/,'').to_f * 10).to_i
				else
					calories = nil
				end
				if @headers['Weight']
					weight = (line[@headers['Weight']].gsub(/^\s*/,'').gsub(/\s*/,'').to_f * 10).to_i
				else
					weight = nil
				end
				if @headers['Steps']
					steps = (line[@headers['Steps']].gsub(/^\s*/,'').gsub(/\s*/,'').to_f * 10).to_i
				else
					steps = nil
				end
				if @headers['Flights']
					flights = (line[@headers['Flights']].gsub(/^\s*/,'').gsub(/\s*/,'').to_f * 10).to_i
				else
					flights = nil
				end
				if @headers['Miles']
					miles = (line[@headers['Miles']].gsub(/^\s*/,'').gsub(/\s*/,'').to_f * 10).to_i
				else
					miles = nil
				end
				if ! date.blank?
					data = HealthDatum.where("user_id = ? AND date = ?", current_user.id, date).first
					if ! data
						data = HealthDatum.new
						data.user_id = current_user.id
						data.date = date
						data.resistance = resistance
						data.calories = calories
						data.weight = weight
						data.steps = steps
						data.flights = flights
						data.miles = miles
						data.save
					end
					count += 1
				end
			end
		end
		@messages.push("#{count} records imported");
	end

	private

	def require_health
		unless current_user_role('health')
			redirect_to root_url, alert: "Inadequate permissions: HEALTHIMPORT"
		end
	end

end
