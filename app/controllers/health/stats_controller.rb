class Health::StatsController < ApplicationController

	before_action :require_signed_in
	before_action :require_health

	def index
		@title = "Statistics"
		@data = HealthDatum.where("user_id = ?", current_user.id).order('date')
		@stats = Hash.new

		# overall
		@stats['Overall'] = Hash.new
		calories = 0
		caloriescount = 0
		weight = 0
		weightcount = 0
		steps = 0
		stepscount = 0
		flights = 0
		flightscount = 0
		miles = 0
		milescount = 0
		@data.each do |data|
			if data.calories && data.calories > 0
				calories += data.calories
				caloriescount += 1
			end
			if data.weight && data.weight > 0
				weight += data.weight
				weightcount += 1
			end
			if data.steps && data.steps > 0
				steps += data.steps
				stepscount += 1
			end
			if data.flights && data.flights > 0
				flights += data.flights
				flightscount += 1
			end
			if data.miles && data.miles > 0
				miles += data.miles
				milescount += 1
			end
		end
		@stats['Overall']['All'] = []
		cavg = calories.to_f / caloriescount / 10.0
		wavg = weight.to_f / weightcount / 10.0
		savg = steps.to_f / stepscount
		favg = flights.to_f / flightscount
		mavg = miles.to_f / milescount / 100.0
		@stats['Overall']['All'].push(cavg, '', '', wavg, '', '', savg, '', '', favg, '', '', mavg, '', '')

		# by week
		@stats['By Week'] = Hash.new
		@data.each do |data|
			week = monday(data.date)
			if ! @stats['By Week'][week]
				@stats['By Week'][week] = []
				@stats['By Week'][week][0] = 0.0	# calories avg
				@stats['By Week'][week][1] = 0.0	# calories std
				@stats['By Week'][week][2] = 0		# calories count
				@stats['By Week'][week][3] = 0.0	# weight avg
				@stats['By Week'][week][4] = 0.0	# weight std
				@stats['By Week'][week][5] = 0		# weight count
				@stats['By Week'][week][6] = 0.0	# steps avg
				@stats['By Week'][week][7] = 0.0	# steps std
				@stats['By Week'][week][8] = 0		# steps count
				@stats['By Week'][week][9] = 0.0	# flights avg
				@stats['By Week'][week][10] = 0.0	# flights std
				@stats['By Week'][week][11] = 0		# flights count
				@stats['By Week'][week][12] = 0.0	# miles avg
				@stats['By Week'][week][13] = 0.0	# miles std
				@stats['By Week'][week][14] = 0		# miles count
			end
			if data.calories && data.calories > 0
				t = data.calories.to_f / 10.0
				@stats['By Week'][week][0] += t
				@stats['By Week'][week][1] += t * t
				@stats['By Week'][week][2] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Week'][week][3] += t
				@stats['By Week'][week][4] += t * t
				@stats['By Week'][week][5] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@stats['By Week'][week][6] += t
				@stats['By Week'][week][7] += t * t
				@stats['By Week'][week][8] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights
				@stats['By Week'][week][9] += t
				@stats['By Week'][week][10] += t * t
				@stats['By Week'][week][11] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@stats['By Week'][week][12] += t
				@stats['By Week'][week][13] += t * t
				@stats['By Week'][week][14] += 1
			end
		end
		@stats['By Week'].each do |week, values|
			if values[2] != 0
				values[0] = values[0] / values[2]
				values[1] = Math.sqrt( (values[1] / values[2]) - (values[0] * values[0]))
			end
			if values[5] != 0
				values[3] = values[3] / values[5]
				values[4] = Math.sqrt( (values[4] / values[5]) - (values[3] * values[3]))
			end
			if values[8] != 0
				values[6] = values[6] / values[8]
				values[7] = Math.sqrt( (values[7] / values[8]) - (values[6] * values[6]))
			end
			if values[11] != 0
				values[9] = values[9] / values[11]
				values[10] = Math.sqrt( (values[10] / values[11]) - (values[9] * values[9]))
			end
			if values[14] != 0
				values[12] = values[12] / values[14]
				values[13] = Math.sqrt( (values[13] / values[14]) - (values[12] * values[12]))
			end
		end

		# by day of week
		@stats['By Day Of Week'] = Hash.new
		@data.each do |data|
			wday = dow(data.date)
			if ! @stats['By Day Of Week'][wday]
				@stats['By Day Of Week'][wday] = []
				@stats['By Day Of Week'][wday][0] = 0.0		# calories avg
				@stats['By Day Of Week'][wday][1] = 0.0		# calories std
				@stats['By Day Of Week'][wday][2] = 0		# calories count
				@stats['By Day Of Week'][wday][3] = 0.0		# weight avg
				@stats['By Day Of Week'][wday][4] = 0.0		# weight std
				@stats['By Day Of Week'][wday][5] = 0		# weight count
				@stats['By Day Of Week'][wday][6] = 0.0		# steps avg
				@stats['By Day Of Week'][wday][7] = 0.0		# steps std
				@stats['By Day Of Week'][wday][8] = 0		# steps count
				@stats['By Day Of Week'][wday][9] = 0.0		# flights avg
				@stats['By Day Of Week'][wday][10] = 0.0	# flights std
				@stats['By Day Of Week'][wday][11] = 0		# flights count
				@stats['By Day Of Week'][wday][12] = 0.0	# miles avg
				@stats['By Day Of Week'][wday][13] = 0.0	# miles std
				@stats['By Day Of Week'][wday][14] = 0		# miles count
			end
			if data.calories && data.calories > 0
				t = data.calories.to_f / 10.0
				@stats['By Day Of Week'][wday][0] += t
				@stats['By Day Of Week'][wday][1] += t * t
				@stats['By Day Of Week'][wday][2] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Day Of Week'][wday][3] += t
				@stats['By Day Of Week'][wday][4] += t * t
				@stats['By Day Of Week'][wday][5] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@stats['By Day Of Week'][wday][6] += t
				@stats['By Day Of Week'][wday][7] += t * t
				@stats['By Day Of Week'][wday][8] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights.to_f
				@stats['By Day Of Week'][wday][9] += t
				@stats['By Day Of Week'][wday][10] += t * t
				@stats['By Day Of Week'][wday][11] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@stats['By Day Of Week'][wday][12] += t
				@stats['By Day Of Week'][wday][13] += t * t
				@stats['By Day Of Week'][wday][14] += 1
			end
		end
		@stats['By Day Of Week'].each do |wday, values|
			if values[2] != 0
				values[0] = values[0] / values[2]
				values[1] = Math.sqrt( (values[1] / values[2]) - (values[0] * values[0]))
			end
			if values[5] != 0
				values[3] = values[3] / values[5]
				values[4] = Math.sqrt( (values[4] / values[5]) - (values[3] * values[3]))
			end
			if values[8] != 0
				values[6] = values[6] / values[8]
				values[7] = Math.sqrt( (values[7] / values[8]) - (values[6] * values[6]))
			end
			if values[11] != 0
				values[9] = values[9] / values[11]
				values[10] = Math.sqrt( (values[10] / values[11]) - (values[9] * values[9]))
			end
			if values[14] != 0
				values[12] = values[12] / values[14]
				values[13] = Math.sqrt( (values[13] / values[14]) - (values[12] * values[12]))
			end
		end

		# by resistance
		@stats['By Resistance'] = Hash.new
		@data.each do |data|
			res = data.resistance
			if ! @stats['By Resistance'][res]
				@stats['By Resistance'][res] = []
				@stats['By Resistance'][res][0] = 0.0	# calories avg
				@stats['By Resistance'][res][1] = 0.0	# calories std
				@stats['By Resistance'][res][2] = 0		# calories count
				@stats['By Resistance'][res][3] = 0.0	# weight avg
				@stats['By Resistance'][res][4] = 0.0	# weight std
				@stats['By Resistance'][res][5] = 0		# weight count
				@stats['By Resistance'][res][6] = 0.0	# steps avg
				@stats['By Resistance'][res][7] = 0.0	# steps std
				@stats['By Resistance'][res][8] = 0		# steps count
				@stats['By Resistance'][res][9] = 0.0	# flights avg
				@stats['By Resistance'][res][10] = 0.0	# flights std
				@stats['By Resistance'][res][11] = 0	# flights count
				@stats['By Resistance'][res][12] = 0.0	# miles avg
				@stats['By Resistance'][res][13] = 0.0	# miles std
				@stats['By Resistance'][res][14] = 0	# miles count
			end
			if data.calories && data.calories > 0
				t = data.calories.to_f / 10.0
				@stats['By Resistance'][res][0] += t
				@stats['By Resistance'][res][1] += t * t
				@stats['By Resistance'][res][2] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Resistance'][res][3] += t
				@stats['By Resistance'][res][4] += t * t
				@stats['By Resistance'][res][5] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@stats['By Resistance'][res][6] += t
				@stats['By Resistance'][res][7] += t * t
				@stats['By Resistance'][res][8] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights.to_f
				@stats['By Resistance'][res][9] += t
				@stats['By Resistance'][res][10] += t * t
				@stats['By Resistance'][res][11] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@stats['By Resistance'][res][12] += t
				@stats['By Resistance'][res][13] += t * t
				@stats['By Resistance'][res][14] += 1
			end
		end
		@stats['By Resistance'].each do |res, values|
			if values[2] != 0
				values[0] = values[0] / values[2]
				values[1] = Math.sqrt( (values[1] / values[2]) - (values[0] * values[0]))
			end
			if values[5] != 0
				values[3] = values[3] / values[5]
				values[4] = Math.sqrt( (values[4] / values[5]) - (values[3] * values[3]))
			end
			if values[8] != 0
				values[6] = values[6] / values[8]
				values[7] = Math.sqrt( (values[7] / values[8]) - (values[6] * values[6]))
			end
			if values[11] != 0
				values[9] = values[9] / values[11]
				values[10] = Math.sqrt( (values[10] / values[11]) - (values[9] * values[9]))
			end
			if values[14] != 0
				values[12] = values[12] / values[14]
				values[13] = Math.sqrt( (values[13] / values[14]) - (values[12] * values[12]))
			end
		end

	end

	private

	def require_health
		unless current_user_role('health')
			redirect_to users_path, alert: "Inadequate permissions: HEALTHSTATS"
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
