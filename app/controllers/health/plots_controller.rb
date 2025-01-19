class Health::PlotsController < ApplicationController

	before_action :require_signed_in
	before_action :require_health

	def index
		@title = "Plots"
		@data = HealthDatum.where("user_id = ?", current_user.id).order('date')

		@charts = Hash.new

		# Daily and weekly average
		# @charts['Daily'][measure]
		#		measure = ['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Weight', 'Steps', 'Flights', 'Miles']
		#	['dates'][date] = [list of line values]
		#	['lines'] = ['Daily', 'Weekly Average']
		@charts['Daily'] = Hash.new
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			@charts['Daily'][type] = Hash.new
			@charts['Daily'][type]['dates'] = Hash.new
			@charts['Daily'][type]['lines'] = ['Daily', '7 Day Average', '30 Day Average']
		end
		aerobic_cal = Hash.new
		aerobic_ical = 0
		active_cal = Hash.new
		active_ical = 0
		resting_cal = Hash.new
		resting_ical = 0
		total_cal = Hash.new
		total_ical = 0
		wgt = Hash.new
		iwgt = 0
		steps = Hash.new
		isteps = 0
		flights = Hash.new
		iflights = 0
		miles = Hash.new
		imiles = 0
		@data.each do |data|
			calflag = 0
			tcal = 0
			if data.aerobic_calories && data.aerobic_calories > 0
				aerobic_cal[aerobic_ical] = data.aerobic_calories.to_f / 10.0
				tcal += aerobic_cal[aerobic_ical]
				calflag += 1
				@charts['Daily']['Aerobic Calories']['dates'][data.date] = [aerobic_cal[aerobic_ical], 0, 0]
				if aerobic_ical >= 6
					t = 0
					(aerobic_ical-6..aerobic_ical).each do |i|
						t += aerobic_cal[i]
					end
					@charts['Daily']['Aerobic Calories']['dates'][data.date][1] = t.to_f / 7.0
				end
				if aerobic_ical >= 29
					t = 0
					(aerobic_ical-29..aerobic_ical).each do |i|
						t += aerobic_cal[i]
					end
					@charts['Daily']['Aerobic Calories']['dates'][data.date][2] = t.to_f / 30.0
				end
				aerobic_ical += 1
			end
			if data.active_calories && data.active_calories > 0
				active_cal[active_ical] = data.active_calories.to_f / 1000.0
				tcal += active_cal[active_ical]
				calflag += 1
				@charts['Daily']['Active Calories']['dates'][data.date] = [active_cal[active_ical], 0, 0]
				if active_ical >= 6
					t = 0
					(active_ical-6..active_ical).each do |i|
						t += active_cal[i]
					end
					@charts['Daily']['Active Calories']['dates'][data.date][1] = t.to_f / 7.0
				end
				if active_ical >= 29
					t = 0
					(active_ical-29..active_ical).each do |i|
						t += active_cal[i]
					end
					@charts['Daily']['Active Calories']['dates'][data.date][2] = t.to_f / 30.0
				end
				active_ical += 1
			end
			if data.resting_calories && data.resting_calories > 0
				resting_cal[resting_ical] = data.resting_calories.to_f / 1000.0
				tcal += resting_cal[resting_ical]
				calflag += 1
				@charts['Daily']['Resting Calories']['dates'][data.date] = [resting_cal[resting_ical], 0, 0]
				if resting_ical >= 6
					t = 0
					(resting_ical-6..resting_ical).each do |i|
						t += resting_cal[i]
					end
					@charts['Daily']['Resting Calories']['dates'][data.date][1] = t.to_f / 7.0
				end
				if resting_ical >= 29
					t = 0
					(resting_ical-29..resting_ical).each do |i|
						t += resting_cal[i]
					end
					@charts['Daily']['Resting Calories']['dates'][data.date][2] = t.to_f / 30.0
				end
				resting_ical += 1
				calflag += 1
			end
			if calflag > 0
				total_cal[total_ical] = tcal
				@charts['Daily']['Total Calories']['dates'][data.date] = [total_cal[total_ical], 0, 0]
				if total_ical >= 6
					t = 0
					(total_ical-6..total_ical).each do |i|
						t += total_cal[i]
					end
					@charts['Daily']['Total Calories']['dates'][data.date][1] = t.to_f / 7.0
				end
				if total_ical >= 29
					t = 0
					(total_ical-29..total_ical).each do |i|
						t += total_cal[i]
					end
					@charts['Daily']['Total Calories']['dates'][data.date][2] = t.to_f / 30.0
				end
				total_ical += 1
			end
			if data.weight && data.weight > 0
				wgt[iwgt] = data.weight.to_f / 10.0
				@charts['Daily']['Weight']['dates'][data.date] = [wgt[iwgt], 0, 0]
				if iwgt >= 6
					t = 0
					(iwgt-6..iwgt).each do |i|
						t += wgt[i]
					end
					@charts['Daily']['Weight']['dates'][data.date][1] = t.to_f / 7.0
				end
				if iwgt >= 29
					t = 0
					(iwgt-29..iwgt).each do |i|
						t += wgt[i]
					end
					@charts['Daily']['Weight']['dates'][data.date][2] = t.to_f / 30.0
				end
				iwgt += 1
			end
			if data.steps && data.steps > 0
				steps[isteps] = data.steps.to_f
				@charts['Daily']['Steps']['dates'][data.date] = [steps[isteps], 0, 0]
				if isteps >= 6
					t = 0
					(isteps-6..isteps).each do |i|
						t += steps[i]
					end
					@charts['Daily']['Steps']['dates'][data.date][1] = t.to_f / 7.0
				end
				if isteps >= 29
					t = 0
					(isteps-29..isteps).each do |i|
						t += steps[i]
					end
					@charts['Daily']['Steps']['dates'][data.date][2] = t.to_f / 30.0
				end
				isteps += 1
			end
			if data.flights && data.flights > 0
				flights[iflights] = data.flights.to_f
				@charts['Daily']['Flights']['dates'][data.date] = [flights[iflights], 0, 0]
				if iflights >= 6
					t = 0
					(iflights-6..iflights).each do |i|
						t += flights[i]
					end
					@charts['Daily']['Flights']['dates'][data.date][1] = t.to_f / 7.0
				end
				if iflights >= 29
					t = 0
					(iflights-29..iflights).each do |i|
						t += flights[i]
					end
					@charts['Daily']['Flights']['dates'][data.date][2] = t.to_f / 30.0
				end
				iflights += 1
			end
			if data.miles && data.miles > 0
				miles[imiles] = data.miles.to_f / 100.0
				@charts['Daily']['Miles']['dates'][data.date] = [miles[imiles], 0, 0]
				if imiles >= 6
					t = 0
					(imiles-6..imiles).each do |i|
						t += miles[i]
					end
					@charts['Daily']['Miles']['dates'][data.date][1] = t.to_f / 7.0
				end
				if imiles >= 29
					t = 0
					(imiles-29..imiles).each do |i|
						t += miles[i]
					end
					@charts['Daily']['Miles']['dates'][data.date][2] = t.to_f / 30.0
				end
				imiles += 1
			end
		end
		['Total Calories', 'Aerobic Calories', 'Active Calories', 'Resting Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			if @charts['Daily'][type]['dates'].count == 0
				@charts['Daily'].delete(type)
			end
		end

		# by weekly average
		# @charts['By Weekly Average][measure]
		#		measure = ['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles']
		#	['dates'][date] = [list of line values]
		#	['lines'] = [list of line names]
		@charts['By Weekly Average'] = Hash.new
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			@charts['By Weekly Average'][type] = Hash.new
			@charts['By Weekly Average'][type]['dates'] = Hash.new
			@charts['By Weekly Average'][type]['lines'] = [type]
		end
		@counts = Hash.new
		@counts['Aerobic Calories'] = Hash.new
		@counts['Active Calories'] = Hash.new
		@counts['Resting Calories'] = Hash.new
		@counts['Total Calories'] = Hash.new
		@counts['Weight'] = Hash.new
		@counts['Steps'] = Hash.new
		@counts['Flights'] = Hash.new
		@counts['Miles'] = Hash.new
		@data.each do |data|
			week = monday(data.date)
			['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
				if ! @charts['By Weekly Average'][type]['dates'][week]
					@charts['By Weekly Average'][type]['dates'][week] = [0]
					@counts[type][week] = 0
				end
			end
			calflag = 0
			tcal = 0
			if data.aerobic_calories && data.aerobic_calories > 0
				t = data.aerobic_calories.to_f / 10.0
				tcal += t
				calflag += 1
				@charts['By Weekly Average']['Aerobic Calories']['dates'][week][0] += t
				@counts['Aerobic Calories'][week] += 1
			end
			if data.active_calories && data.active_calories > 0
				t = data.active_calories.to_f / 1000.0
				tcal += t
				calflag += 1
				@charts['By Weekly Average']['Active Calories']['dates'][week][0] += t
				@counts['Active Calories'][week] += 1
				calflag += 1
			end
			if calflag > 0
				t = tcal
				@charts['By Weekly Average']['Total Calories']['dates'][week][0] += t
				@counts['Total Calories'][week] += 1
			end
			if data.resting_calories && data.resting_calories > 0
				t = data.resting_calories.to_f / 1000.0
				tcal += t
				calflag += 1
				@charts['By Weekly Average']['Resting Calories']['dates'][week][0] += t
				@counts['Resting Calories'][week] += 1
				calflag += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@charts['By Weekly Average']['Weight']['dates'][week][0] += t
				@counts['Weight'][week] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@charts['By Weekly Average']['Steps']['dates'][week][0] += t
				@counts['Steps'][week] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights.to_f
				@charts['By Weekly Average']['Flights']['dates'][week][0] += t
				@counts['Flights'][week] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@charts['By Weekly Average']['Miles']['dates'][week][0] += t
				@counts['Miles'][week] += 1
			end
		end
		@charts['By Weekly Average']['Total Calories']['dates'].each do |week, values|
				t = @charts['By Weekly Average']['Aerobic Calories']['dates'][week][0] + @charts['By Weekly Average']['Active Calories']['dates'][week][0] + @charts['By Weekly Average']['Resting Calories']['dates'][week][0]
				@charts['By Weekly Average']['Total Calories']['dates'][week][0] = t
				@counts['Total Calories'][week] += 7
		end
		@charts['By Weekly Average'].each do |type, values|
			values['dates'].each do |date, value|
				if @counts[type][date] > 0
					@charts['By Weekly Average'][type]['dates'][date][0] /= @counts[type][date]
				end
			end
		end
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			flag = false
			@charts['By Weekly Average'][type]['dates'].each do |date, values|
				if values[0] != 0
					flag = true
					break
				end
			end
			if flag == false
				@charts['By Weekly Average'].delete(type)
			end
		end

		# By Day of Week
		# @charts['By Day of Week'][measure]
		#		measure = ['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles']
		#	['dates'][date] = [list of line values]
		#	['lines'] = [list of line names]
		@charts['By Day of Week'] = Hash.new
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			@charts['By Day of Week'][type] = Hash.new
			@charts['By Day of Week'][type]['dates'] = Hash.new
			@charts['By Day of Week'][type]['lines'] = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
		end
		lweek = ''
		@data.each do |data|
			week = monday(data.date)
			if week != lweek
				['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
					@charts['By Day of Week'][type]['dates'][week] = [0,0,0,0,0,0,0]
				end
				lweek = week
			end
			wday = data.date.wday - 1
			if wday < 0
				wday = 6
			end
			calflag = 0
			tcal = 0
			if data.aerobic_calories && data.aerobic_calories > 0
				t = data.aerobic_calories.to_f / 10.0
				tcal += t
				calflag += 1
				@charts['By Day of Week']['Aerobic Calories']['dates'][week][wday] += t
			end
			if data.active_calories && data.active_calories > 0
				t = data.active_calories.to_f / 1000.0
				tcal += t
				calflag += 1
				@charts['By Day of Week']['Active Calories']['dates'][week][wday] += t
			end
			if data.resting_calories && data.resting_calories > 0
				t = data.resting_calories.to_f / 1000.0
				tcal += t
				calflag += 1
				@charts['By Day of Week']['Resting Calories']['dates'][week][wday] += t
			end
			if calflag > 0
				t = tcal
				@charts['By Day of Week']['Total Calories']['dates'][week][wday] += t
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@charts['By Day of Week']['Weight']['dates'][week][wday] += t
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@charts['By Day of Week']['Steps']['dates'][week][wday] += t
			end
			if data.flights && data.flights > 0
				t = data.flights.to_f
				@charts['By Day of Week']['Flights']['dates'][week][wday] += t
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@charts['By Day of Week']['Miles']['dates'][week][wday] += t
			end
		end
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			flag = false
			@charts['By Day of Week'][type]['dates'].each do |date, values|
				values.each do |value|
					if value != 0
						flag = true
						break
					end
				end
				if flag == true
					break
				end
			end
			if flag == false
				@charts['By Day of Week'].delete(type)
			end
		end

		# by resistance
		# @charts['By Resistance'][measure]
		#		measure = ['Aerobic Calories', 'Active Calories', 'Total Calories', 'Resting Calories', 'Weight', 'Steps', 'Flights', 'Miles']
		#	['dates'][date] = [list of line values]
		#	['lines'] = [list of line names]
		@resistances = Hash.new
		@data.each do |data|
			if data.resistance && data.resistance > 0
				@resistances[data.resistance] = 1
			end
		end
		@resistances = @resistances.sort_by { |resistance, value| resistance}.to_h
		i = 0
		@resistances.each do |resistance, value|
			@resistances[resistance] = i
			i += 1
		end
		@charts['By Resistance'] = Hash.new
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			@charts['By Resistance'][type] = Hash.new
			@charts['By Resistance'][type]['dates'] = Hash.new
			@charts['By Resistance'][type]['lines'] = []
			@resistances.each do |resistance, value|
				@charts['By Resistance'][type]['lines'].push(resistance)
			end
		end
		@data.each do |data|
			['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
				@charts['By Resistance'][type]['dates'][data.date] = []
				@resistances.each do |resistance, value|
					@charts['By Resistance'][type]['dates'][data.date].push(0)
				end
				if type == 'Aerobic Calories'
					v = data.aerobic_calories.to_f / 10.0
				end
				if type == 'Active Calories'
					v = data.active_calories.to_f / 1000.0
				end
				if type == 'Resting Calories'
					v = data.resting_calories.to_f / 1000.0
				end
				if type == 'Total Calories'
					v = data.aerobic_calories.to_f / 10.0 + data.active_calories.to_f / 1000.0 + data.resting_calories.to_f / 1000.0
				end
				if type == 'Weight'
					v = data.weight.to_f / 10.0
				end
				if type == 'Steps'
					v = data.steps.to_f
				end
				if type == 'Flights'
					v = data.flights.to_f
				end
				if type == 'Miles'
					v = data.miles.to_f / 100.0
				end
				if @resistances[data.resistance]
					@charts['By Resistance'][type]['dates'][data.date][@resistances[data.resistance]] = v
				end
			end
		end
		['Aerobic Calories', 'Active Calories', 'Resting Calories', 'Total Calories', 'Weight', 'Steps', 'Flights', 'Miles'].each do |type|
			flag = false
			@charts['By Resistance'][type]['dates'].each do |date, values|
				values.each do |value|
					if value != 0
						flag = true
						break
					end
				end
				if flag == true
					break
				end
			end
			if flag == false
				@charts['By Resistance'].delete(type)
			end
		end

	end

	private

	def require_health
		unless current_user_role('health')
			redirect_to users_path, alert: "Inadequate permissions: HEALTHIMPORT"
		end
	end

	def dow(date)
		wday = date.wday
		if wday == 0
			return('Sunday')
		elsif wday == 1
			return('Monday')
		elsif wday == 2
			return('Tuesday')
		elsif wday == 3
			return('Wednesday')
		elsif wday == 4
			return('Thursday')
		elsif wday == 5
			return('Friday')
		elsif wday == 6
			return('Saturday')
		end
	end

end
