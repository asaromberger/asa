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
		@data.each do |data|
			if data.calories && data.calories > 0
				calories += data.calories
				caloriescount += 1
			end
			if data.weight && data.weight > 0
				weight += data.weight
				weightcount += 1
			end
		end
		@stats['Overall']['All'] = []
		cavg = calories.to_f / caloriescount / 10.0
		cstd = 0.0
		wavg = weight.to_f / weightcount / 10.0
		wstd = 0.0
		@stats['Overall']['All'].push(cavg, cstd, wavg, wstd)

		# by week
		@stats['By Week'] = Hash.new
		@data.each do |data|
			week = monday(data.date)
if data.date <= '2020-12-14'.to_date
	puts("date: #{data.date}  week: #{week}")
end
			if ! @stats['By Week'][week]
				@stats['By Week'][week] = []
				@stats['By Week'][week][0] = 0.0	# calories avg
				@stats['By Week'][week][1] = 0.0	# calories std
				@stats['By Week'][week][2] = 0.0	# weight avg
				@stats['By Week'][week][3] = 0.0	# weight std
				@stats['By Week'][week][4] = 0	# calories count
				@stats['By Week'][week][5] = 0	# weight count
			end
			if data.calories && data.calories > 0
				t = data.calories.to_f / 10.0
				@stats['By Week'][week][0] += t
				@stats['By Week'][week][1] += t * t
				@stats['By Week'][week][4] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Week'][week][2] += t
				@stats['By Week'][week][3] += t * t
				@stats['By Week'][week][5] += 1
			end
		end
		@stats['By Week'].each do |week, values|
			if values[4] != 0
				values[0] = values[0] / values[4]
				values[1] = Math.sqrt( (values[1] / values[4]) - (values[0] * values[0]))
			end
			if values[5] != 0
				values[2] = values[2] / values[5]
				values[3] = Math.sqrt( (values[3] / values[5]) - (values[2] * values[2]))
			end
		end

		# by day of week
		@stats['By Day Of Week'] = Hash.new
		@data.each do |data|
			wday = dow(data.date)
			if ! @stats['By Day Of Week'][wday]
				@stats['By Day Of Week'][wday] = []
				@stats['By Day Of Week'][wday][0] = 0.0
				@stats['By Day Of Week'][wday][1] = 0.0
				@stats['By Day Of Week'][wday][2] = 0.0
				@stats['By Day Of Week'][wday][3] = 0.0
				@stats['By Day Of Week'][wday][4] = 0	# calories count
				@stats['By Day Of Week'][wday][5] = 0	# weight count
			end
			if data.calories && data.calories > 0
				t = data.calories.to_f / 10.0
				@stats['By Day Of Week'][wday][0] += t
				@stats['By Day Of Week'][wday][1] += t * t
				@stats['By Day Of Week'][wday][4] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Day Of Week'][wday][2] += t
				@stats['By Day Of Week'][wday][3] += t * t
				@stats['By Day Of Week'][wday][5] += 1
			end
		end
		@stats['By Day Of Week'].each do |wday, values|
			if values[4] != 0
				values[0] = values[0] / values[4]
				values[1] = Math.sqrt( (values[1] / values[4]) - (values[0] * values[0]))
			end
			if values[5] != 0
				values[2] = values[2] / values[5]
				values[3] = Math.sqrt( (values[3] / values[5]) - (values[2] * values[2]))
			end
		end

		# by resistance
		@stats['By Resistance'] = Hash.new
		@data.each do |data|
			res = data.resistance
			if ! @stats['By Resistance'][res]
				@stats['By Resistance'][res] = []
				@stats['By Resistance'][res][0] = 0.0
				@stats['By Resistance'][res][1] = 0.0
				@stats['By Resistance'][res][2] = 0.0
				@stats['By Resistance'][res][3] = 0.0
				@stats['By Resistance'][res][4] = 0	# calories count
				@stats['By Resistance'][res][5] = 0	# weight count
			end
			if data.calories && data.calories > 0
				t = data.calories.to_f / 10.0
				@stats['By Resistance'][res][0] += t
				@stats['By Resistance'][res][1] += t * t
				@stats['By Resistance'][res][4] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Resistance'][res][2] += t
				@stats['By Resistance'][res][3] += t * t
				@stats['By Resistance'][res][5] += 1
			end
		end
		@stats['By Resistance'].each do |res, values|
			if values[4] != 0
				values[0] = values[0] / values[4]
				values[1] = Math.sqrt( (values[1] / values[4]) - (values[0] * values[0]))
			end
			if values[5] != 0
				values[2] = values[2] / values[5]
				values[3] = Math.sqrt( (values[3] / values[5]) - (values[2] * values[2]))
			end
		end

	end

	private

	def require_health
		unless current_user_role('health')
			redirect_to root_url, alert: "Inadequate permissions: HEALTHSTATS"
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
