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
		@messages = []
		count_new = 0
		count_update = 0
		@input = File.open(sheet.tempfile, 'rb').read
		if @input.match(/^<.xml/)
			# XML
			@values = Hash.new
			@input.split(/[\n\r]+/).each do |line|
				if line.match(/creationDate/)
					t = line.sub(/.*creationDate="/, '')
					date = t.sub(/ .*/, '').to_date
					if ! @values[date]
						@values[date] = Hash.new
					end
					if line.match(/StepCount/)
						t = line.sub(/.*value="/, '')
						value = t.sub(/".*/, '').to_i
						if ! @values[date]['steps']
							@values[date]['steps'] = 0
						end
						@values[date]['steps'] += value
					elsif line.match(/Distance/)
						t = line.sub(/.*value="/, '')
						value = t.sub(/".*/, '').to_f
						if ! @values[date]['miles']
							@values[date]['miles'] = 0
						end
						@values[date]['miles'] += value * 100
					elsif line.match(/Flights/)
						t = line.sub(/.*value="/, '')
						value = t.sub(/".*/, '').to_i
						if ! @values[date]['flights']
							@values[date]['flights'] = 0
						end
						@values[date]['flights'] += value
					elsif line.match(/ActiveEnergyBurned/)
						t = line.sub(/.*value="/, '')
						value = t.sub(/".*/, '').to_f
						if ! @values[date]['active_calories']
							@values[date]['active_calories'] = 0
						end
						@values[date]['active_calories'] += value * 1000
					elsif line.match(/BasalEnergyBurned/)
						t = line.sub(/.*value="/, '')
						value = t.sub(/".*/, '').to_f
						if ! @values[date]['resting_calories']
							@values[date]['resting_calories'] = 0
						end
						@values[date]['resting_calories'] += value * 1000
					end
				end
			end
			@values.each do |date, values|
				data = HealthDatum.where("user_id = ? AND date = ?", current_user.id, date).first
				if ! data
					data = HealthDatum.new
					data.user_id = current_user.id
					data.date = date
					count_new += 1
				else
					count_update += 1
				end
				if values['steps']
					data.steps = values['steps']
				end
				if values['miles']
					data.miles = values['miles']
				end
				if values['flights']
					data.flights = values['flights']
				end
				if values['active_calories']
					data.active_calories = values['active_calories']
				end
				if values['resting_calories']
					data.resting_calories = values['resting_calories']
				end
				data.save
			end
		else
			# CSV
			data = CSV.parse(@input)
			@headers = Hash.new
			data.each do |line|
				if @headers.count == 0
					(0..line.count-1).each do |i|
						if line[i].match('Date')
							@headers['Date'] = i
						elsif line[i].match('Resistance')
							@headers['Resistance'] = i
						elsif line[i].match('Aerobic Calories')
							@headers['Aerobic Calories'] = i
						elsif line[i].match('Weight')
							@headers['Weight'] = i
						elsif line[i].match('Steps')
							@headers['Steps'] = i
						elsif line[i].match('Flights')
							@headers['Flights'] = i
						elsif line[i].match('Miles')
							@headers['Miles'] = i
						elsif line[i].match('Active Calories')
							@headers['Active Calories'] = i
						elsif line[i].match('Resting Calories')
							@headers['Resting Calories'] = i
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
					if @headers['Aerobic Calories'] && line[@headers['Aerobic Calories']]
						aerobic_calories = line[@headers['Aerobic Calories']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
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
					if @headers['Active Calories']
						active_calories = line[@headers['Active Calories']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
					else
						active_calories = nil
					end
					if @headers['Resting Calories']
						resting_calories = line[@headers['Resting Calories']].gsub(/^\s*/,'').gsub(/\s*/,'').to_i
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
						if aerobic_calories
							data.aerobic_calories = aerobic_calories
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
						if active_calories
							data.active_calories = active_calories
						end
						if resting_calories
							data.resting_calories = resting_calories
						end
						data.save
					end
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
