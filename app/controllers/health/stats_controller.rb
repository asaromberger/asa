class Health::StatsController < ApplicationController

	before_action :require_signed_in
	before_action :require_health

	def index
		@title = "Statistics"
		@data = HealthDatum.where("user_id = ?", current_user.id).order('date')
		@stats = Hash.new

		# overall
		@stats['Overall'] = Hash.new
		aerobic_calories = 0
		aerobic_caloriescount = 0
		active_calories = 0
		active_caloriescount = 0
		resting_calories = 0
		resting_caloriescount = 0
		weight = 0
		weightcount = 0
		steps = 0
		stepscount = 0
		flights = 0
		flightscount = 0
		miles = 0
		milescount = 0
		@data.each do |data|
			if data.aerobic_calories && data.aerobic_calories > 0
				aerobic_calories += data.aerobic_calories
				aerobic_caloriescount += 1
			end
			if data.active_calories && data.active_calories > 0
				active_calories += data.active_calories
				active_caloriescount += 1
			end
			if data.resting_calories && data.resting_calories > 0
				resting_calories += data.resting_calories
				resting_caloriescount += 1
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
		aerobic_cavg = aerobic_calories.to_f / aerobic_caloriescount / 10.0
		active_cavg = active_calories.to_f / active_caloriescount / 1000.0
		resting_cavg = resting_calories.to_f / resting_caloriescount / 1000.0
		total_cavg = aerobic_cavg + active_cavg + resting_cavg
		wavg = weight.to_f / weightcount / 10.0
		savg = steps.to_f / stepscount
		favg = flights.to_f / flightscount
		mavg = miles.to_f / milescount / 100.0
		@stats['Overall']['All'] = Hash.new
		@stats['Overall']['All']['aerobic_calories_avg'] = aerobic_cavg
		@stats['Overall']['All']['aerobic_calories_std'] = ''
		@stats['Overall']['All']['aerobic_calories_count'] = ''
		@stats['Overall']['All']['active_calories_avg'] = active_cavg
		@stats['Overall']['All']['active_calories_std'] = ''
		@stats['Overall']['All']['active_calories_cnt'] = ''
		@stats['Overall']['All']['resting_calories_avg'] = resting_cavg
		@stats['Overall']['All']['resting_calories_std'] = ''
		@stats['Overall']['All']['resting_calories_count'] = ''
		@stats['Overall']['All']['total_calories_avg'] = resting_cavg
		@stats['Overall']['All']['total_calories_std'] = ''
		@stats['Overall']['All']['total_calories_count'] = ''
		@stats['Overall']['All']['weight_avg'] = wavg
		@stats['Overall']['All']['weight_std'] = ''
		@stats['Overall']['All']['weight_count'] = ''
		@stats['Overall']['All']['steps_avg'] = savg
		@stats['Overall']['All']['steps_std'] = ''
		@stats['Overall']['All']['steps_count'] = ''
		@stats['Overall']['All']['flights_avg'] = favg
		@stats['Overall']['All']['flights_std'] = ''
		@stats['Overall']['All']['flights_count'] = ''
		@stats['Overall']['All']['miles_avg'] = mavg
		@stats['Overall']['All']['miles_std'] = ''
		@stats['Overall']['All']['miles_count'] = ''

		# by week
		@stats['By Week'] = Hash.new
		@data.each do |data|
			week = monday(data.date)
			if ! @stats['By Week'][week]
				@stats['By Week'][week] = Hash.new
				@stats['By Week'][week]['aerobic_calories_avg'] = 0.0
				@stats['By Week'][week]['aerobic_calories_std'] = 0.0
				@stats['By Week'][week]['aerobic_calories_count'] = 0
				@stats['By Week'][week]['active_calories_avg'] = 0.0
				@stats['By Week'][week]['active_calories_std'] = 0.0
				@stats['By Week'][week]['active_calories_cnt'] = 0
				@stats['By Week'][week]['resting_calories_avg'] = 0.0
				@stats['By Week'][week]['resting_calories_std'] = 0.0
				@stats['By Week'][week]['resting_calories_count'] = 0
				@stats['By Week'][week]['total_calories_avg'] = 0.0
				@stats['By Week'][week]['total_calories_std'] = 0.0
				@stats['By Week'][week]['total_calories_count'] = 0
				@stats['By Week'][week]['weight_avg'] = 0.0
				@stats['By Week'][week]['weight_std'] = 0.0
				@stats['By Week'][week]['weight_count'] = 0
				@stats['By Week'][week]['steps_avg'] = 0.0
				@stats['By Week'][week]['steps_std'] = 0.0
				@stats['By Week'][week]['steps_count'] = 0
				@stats['By Week'][week]['flights_avg'] = 0.0
				@stats['By Week'][week]['flights_std'] = 0.0
				@stats['By Week'][week]['flights_count'] = 0
				@stats['By Week'][week]['miles_avg'] = 0.0
				@stats['By Week'][week]['miles_std'] = 0.0
				@stats['By Week'][week]['miles_count'] = 0
			end
			tcalcnt = 0
			tcalv = 0
			if data.aerobic_calories && data.aerobic_calories > 0
				t = data.aerobic_calories.to_f / 10.0
				@stats['By Week'][week]['aerobic_calories_avg'] += t
				@stats['By Week'][week]['aerobic_calories_std'] += t * t
				@stats['By Week'][week]['aerobic_calories_count'] += 1
				tcalv += t
				tcalcnt = 1
			end
			if data.active_calories && data.active_calories > 0
				t = data.active_calories.to_f / 1000.0
				@stats['By Week'][week]['active_calories_avg'] += t
				@stats['By Week'][week]['active_calories_std'] += t * t
				@stats['By Week'][week]['active_calories_cnt'] += 1
				tcalv += t
				tcalcnt = 1
			end
			if data.resting_calories && data.resting_calories > 0
				t = data.resting_calories.to_f / 1000.0
				@stats['By Week'][week]['resting_calories_avg'] += t
				@stats['By Week'][week]['resting_calories_std'] += t * t
				@stats['By Week'][week]['resting_calories_count'] += 1
				tcalv += t
				tcalcnt = 1
			end
			if tcalcnt > 0
				@stats['By Week'][week]['total_calories_avg'] += tcalv
				@stats['By Week'][week]['total_calories_std'] += tcalv * tcalv
				@stats['By Week'][week]['total_calories_count'] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Week'][week]['weight_avg'] += t
				@stats['By Week'][week]['weight_std'] += t * t
				@stats['By Week'][week]['weight_count'] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@stats['By Week'][week]['steps_avg'] += t
				@stats['By Week'][week]['steps_std'] += t * t
				@stats['By Week'][week]['steps_count'] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights
				@stats['By Week'][week]['flights_avg'] += t
				@stats['By Week'][week]['flights_std'] += t * t
				@stats['By Week'][week]['flights_count'] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@stats['By Week'][week]['miles_avg'] += t
				@stats['By Week'][week]['miles_std'] += t * t
				@stats['By Week'][week]['miles_count'] += 1
			end
		end
		@stats['By Week'].each do |week, values|
			if values['aerobic_calories_count'] != 0
				values['aerobic_calories_avg'] = values['aerobic_calories_avg'] / values['aerobic_calories_count']
				values['aerobic_calories_std'] = Math.sqrt( (values['aerobic_calories_std'] / values['aerobic_calories_count']) - (values['aerobic_calories_avg'] * values['aerobic_calories_avg']))
			end
			if values['active_calories_cnt'] != 0
				values['active_calories_avg'] = values['active_calories_avg'] / values['active_calories_cnt']
				values['active_calories_std'] = Math.sqrt( (values['active_calories_std'] / values['active_calories_cnt']) - (values['active_calories_avg'] * values['active_calories_avg']))
			end
			if values['resting_calories_count'] != 0
				values['resting_calories_avg'] = values['resting_calories_avg'] / values['resting_calories_count']
				values['resting_calories_std'] = Math.sqrt( (values['resting_calories_std'] / values['resting_calories_count']) - (values['resting_calories_avg'] * values['resting_calories_avg']))
			end
			if values['total_calories_count'] != 0
				values['total_calories_avg'] = values['total_calories_avg'] / values['total_calories_count']
				values['total_calories_std'] = Math.sqrt( (values['total_calories_std'] / values['total_calories_count']) - (values['total_calories_avg'] * values['total_calories_avg']))
			end
			if values['weight_count'] != 0
				values['weight_avg'] = values['weight_avg'] / values['weight_count']
				values['weight_std'] = Math.sqrt( (values['weight_std'] / values['weight_count']) - (values['weight_avg'] * values['weight_avg']))
			end
			if values['steps_count'] != 0
				values['steps_avg'] = values['steps_avg'] / values['steps_count']
				values['steps_std'] = Math.sqrt( (values['steps_std'] / values['steps_count']) - (values['steps_avg'] * values['steps_avg']))
			end
			if values['flights_count'] != 0
				values['flights_avg'] = values['flights_avg'] / values['flights_count']
				values['flights_std'] = Math.sqrt( (values['flights_std'] / values['flights_count']) - (values['flights_avg'] * values['flights_avg']))
			end
			if values['miles_count'] != 0
				values['miles_avg'] = values['miles_avg'] / values['miles_count']
				values['miles_std'] = Math.sqrt( (values['miles_std'] / values['miles_count']) - (values['miles_avg'] * values['miles_avg']))
			end
		end

		# by day of week
		@stats['By Day Of Week'] = Hash.new
		@data.each do |data|
			wday = dow(data.date)
			if ! @stats['By Day Of Week'][wday]
				@stats['By Day Of Week'][wday] = Hash.new
				@stats['By Day Of Week'][wday]['aerobic_calories_avg'] = 0.0	
				@stats['By Day Of Week'][wday]['aerobic_calories_std'] = 0.0
				@stats['By Day Of Week'][wday]['aerobic_calories_count'] = 0
				@stats['By Day Of Week'][wday]['active_calories_avg'] = 0.0
				@stats['By Day Of Week'][wday]['active_calories_std'] = 0.0
				@stats['By Day Of Week'][wday]['active_calories_cnt'] = 0
				@stats['By Day Of Week'][wday]['resting_calories_avg'] = 0.0
				@stats['By Day Of Week'][wday]['resting_calories_std'] = 0.0
				@stats['By Day Of Week'][wday]['resting_calories_count'] = 0
				@stats['By Day Of Week'][wday]['total_calories_avg'] = 0.0
				@stats['By Day Of Week'][wday]['total_calories_std'] = 0.0
				@stats['By Day Of Week'][wday]['total_calories_count'] = 0
				@stats['By Day Of Week'][wday]['weight_avg'] = 0.0
				@stats['By Day Of Week'][wday]['weight_std'] = 0.0
				@stats['By Day Of Week'][wday]['weight_count'] = 0
				@stats['By Day Of Week'][wday]['steps_avg'] = 0.0
				@stats['By Day Of Week'][wday]['steps_std'] = 0.0
				@stats['By Day Of Week'][wday]['steps_count'] = 0
				@stats['By Day Of Week'][wday]['flights_avg'] = 0.0
				@stats['By Day Of Week'][wday]['flights_std'] = 0.0
				@stats['By Day Of Week'][wday]['flights_count'] = 0
				@stats['By Day Of Week'][wday]['miles_avg'] = 0.0
				@stats['By Day Of Week'][wday]['miles_std'] = 0.0
				@stats['By Day Of Week'][wday]['miles_count'] = 0
			end
			tcalcnt = 0
			tcalv = 0
			if data.aerobic_calories && data.aerobic_calories > 0
				t = data.aerobic_calories.to_f / 10.0
				@stats['By Day Of Week'][wday]['aerobic_calories_avg'] += t
				@stats['By Day Of Week'][wday]['aerobic_calories_std'] += t * t
				@stats['By Day Of Week'][wday]['aerobic_calories_count'] += 1
				tcalv += t
				tcalcnt = 1
			end
			if data.active_calories && data.active_calories > 0
				t = data.active_calories.to_f / 1000.0
				@stats['By Day Of Week'][wday]['active_calories_avg'] += t
				@stats['By Day Of Week'][wday]['active_calories_std'] += t * t
				@stats['By Day Of Week'][wday]['active_calories_cnt'] += 1
				tcalv += t
				tcalcnt = 1
			end
			if data.resting_calories && data.resting_calories > 0
				t = data.resting_calories.to_f / 1000.0
				@stats['By Day Of Week'][wday]['resting_calories_avg'] += t
				@stats['By Day Of Week'][wday]['resting_calories_std'] += t * t
				@stats['By Day Of Week'][wday]['resting_calories_count'] += 1
				tcalv += t
				tcalcnt = 1
			end
			if tcalcnt > 0
				@stats['By Day Of Week'][wday]['total_calories_avg'] += tcalv
				@stats['By Day Of Week'][wday]['total_calories_std'] += tcalv * tcalv
				@stats['By Day Of Week'][wday]['total_calories_count'] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Day Of Week'][wday]['weight_avg'] += t
				@stats['By Day Of Week'][wday]['weight_std'] += t * t
				@stats['By Day Of Week'][wday]['weight_count'] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@stats['By Day Of Week'][wday]['steps_avg'] += t
				@stats['By Day Of Week'][wday]['steps_std'] += t * t
				@stats['By Day Of Week'][wday]['steps_count'] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights.to_f
				@stats['By Day Of Week'][wday]['flights_avg'] += t
				@stats['By Day Of Week'][wday]['flights_std'] += t * t
				@stats['By Day Of Week'][wday]['flights_count'] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@stats['By Day Of Week'][wday]['miles_avg'] += t
				@stats['By Day Of Week'][wday]['miles_std'] += t * t
				@stats['By Day Of Week'][wday]['miles_count'] += 1
			end
		end
		@stats['By Day Of Week'].each do |wday, values|
			if values['aerobic_calories_count'] != 0
				values['aerobic_calories_avg'] = values['aerobic_calories_avg'] / values['aerobic_calories_count']
				values['aerobic_calories_std'] = Math.sqrt( (values['aerobic_calories_std'] / values['aerobic_calories_count']) - (values['aerobic_calories_avg'] * values['aerobic_calories_avg']))
			end
			if values['active_calories_cnt'] != 0
				values['active_calories_avg'] = values['active_calories_avg'] / values['active_calories_cnt']
				values['active_calories_std'] = Math.sqrt( (values['active_calories_std'] / values['active_calories_cnt']) - (values['active_calories_avg'] * values['active_calories_avg']))
			end
			if values['resting_calories_count'] != 0
				values['resting_calories_avg'] = values['resting_calories_avg'] / values['resting_calories_count']
				values['resting_calories_std'] = Math.sqrt( (values['resting_calories_std'] / values['resting_calories_count']) - (values['resting_calories_avg'] * values['resting_calories_avg']))
			end
			if values['total_calories_count'] != 0
				values['total_calories_avg'] = values['total_calories_avg'] / values['total_calories_count']
				values['total_calories_std'] = Math.sqrt( (values['total_calories_std'] / values['total_calories_count']) - (values['total_calories_avg'] * values['total_calories_avg']))
			end
			if values['weight_count'] != 0
				values['weight_avg'] = values['weight_avg'] / values['weight_count']
				values['weight_std'] = Math.sqrt( (values['weight_std'] / values['weight_count']) - (values['weight_avg'] * values['weight_avg']))
			end
			if values['steps_count'] != 0
				values['steps_avg'] = values['steps_avg'] / values['steps_count']
				values['steps_std'] = Math.sqrt( (values['steps_std'] / values['steps_count']) - (values['steps_avg'] * values['steps_avg']))
			end
			if values['flights_count'] != 0
				values['flights_avg'] = values['flights_avg'] / values['flights_count']
				values['flights_std'] = Math.sqrt( (values['flights_std'] / values['flights_count']) - (values['flights_avg'] * values['flights_avg']))
			end
			if values['miles_count'] != 0
				values['miles_avg'] = values['miles_avg'] / values['miles_count']
				values['miles_std'] = Math.sqrt( (values['miles_std'] / values['miles_count']) - (values['miles_avg'] * values['miles_avg']))
			end
		end

		# by resistance
		@stats['By Resistance'] = Hash.new
		@data.each do |data|
			res = data.resistance
			if ! res || res == 0
				next
			end
			if ! @stats['By Resistance'][res]
				@stats['By Resistance'][res] = Hash.new
				@stats['By Resistance'][res]['aerobic_calories_avg'] = 0.0
				@stats['By Resistance'][res]['aerobic_calories_std'] = 0.0
				@stats['By Resistance'][res]['aerobic_calories_count'] = 0
				@stats['By Resistance'][res]['active_calories_avg'] = 0.0
				@stats['By Resistance'][res]['active_calories_std'] = 0.0
				@stats['By Resistance'][res]['active_calories_cnt'] = 0
				@stats['By Resistance'][res]['resting_calories_avg'] = 0.0
				@stats['By Resistance'][res]['resting_calories_std'] = 0.0
				@stats['By Resistance'][res]['resting_calories_count'] = 0
				@stats['By Resistance'][res]['total_calories_avg'] = 0.0
				@stats['By Resistance'][res]['total_calories_std'] = 0.0
				@stats['By Resistance'][res]['total_calories_count'] = 0
				@stats['By Resistance'][res]['weight_avg'] = 0.0
				@stats['By Resistance'][res]['weight_std'] = 0.0
				@stats['By Resistance'][res]['weight_count'] = 0
				@stats['By Resistance'][res]['steps_avg'] = 0.0
				@stats['By Resistance'][res]['steps_std'] = 0.0
				@stats['By Resistance'][res]['steps_count'] = 0
				@stats['By Resistance'][res]['flights_avg'] = 0.0
				@stats['By Resistance'][res]['flights_std'] = 0.0
				@stats['By Resistance'][res]['flights_count'] = 0
				@stats['By Resistance'][res]['miles_avg'] = 0.0
				@stats['By Resistance'][res]['miles_std'] = 0.0
				@stats['By Resistance'][res]['miles_count'] = 0
			end
			tcalcnt = 0
			tcalv = 0
			if data.aerobic_calories && data.aerobic_calories > 0
				t = data.aerobic_calories.to_f / 10.0
				@stats['By Resistance'][res]['aerobic_calories_avg'] += t
				@stats['By Resistance'][res]['aerobic_calories_std'] += t * t
				@stats['By Resistance'][res]['aerobic_calories_count'] += 1
				tcalv += t
				tcalcnt += 1
			end
			if data.active_calories && data.active_calories > 0
				t = data.active_calories.to_f / 1000.0
				@stats['By Resistance'][res]['active_calories_avg'] += t
				@stats['By Resistance'][res]['active_calories_std'] += t * t
				@stats['By Resistance'][res]['active_calories_cnt'] += 1
				tcalv += t
				tcalcnt += 1
			end
			if data.resting_calories && data.resting_calories > 0
				t = data.resting_calories.to_f / 1000.0
				@stats['By Resistance'][res]['resting_calories_avg'] += t
				@stats['By Resistance'][res]['resting_calories_std'] += t * t
				@stats['By Resistance'][res]['resting_calories_count'] += 1
				tcalv += t
				tcalcnt += 1
			end
			if tcalcnt > 0
				@stats['By Resistance'][res]['total_calories_avg'] += tcalv
				@stats['By Resistance'][res]['total_calories_std'] += tcalv * tcalv
				@stats['By Resistance'][res]['total_calories_count'] += 1
			end
			if data.weight && data.weight > 0
				t = data.weight.to_f / 10.0
				@stats['By Resistance'][res]['weight_avg'] += t
				@stats['By Resistance'][res]['weight_std'] += t * t
				@stats['By Resistance'][res]['weight_count'] += 1
			end
			if data.steps && data.steps > 0
				t = data.steps.to_f
				@stats['By Resistance'][res]['steps_avg'] += t
				@stats['By Resistance'][res]['steps_std'] += t * t
				@stats['By Resistance'][res]['steps_count'] += 1
			end
			if data.flights && data.flights > 0
				t = data.flights.to_f
				@stats['By Resistance'][res]['flights_avg'] += t
				@stats['By Resistance'][res]['flights_std'] += t * t
				@stats['By Resistance'][res]['flights_count'] += 1
			end
			if data.miles && data.miles > 0
				t = data.miles.to_f / 100.0
				@stats['By Resistance'][res]['miles_avg'] += t
				@stats['By Resistance'][res]['miles_std'] += t * t
				@stats['By Resistance'][res]['miles_count'] += 1
			end
		end
		@stats['By Resistance'].each do |res, values|
			if values['aerobic_calories_count'] != 0
				values['aerobic_calories_avg'] = values['aerobic_calories_avg'] / values['aerobic_calories_count']
				values['aerobic_calories_std'] = Math.sqrt( (values['aerobic_calories_std'] / values['aerobic_calories_count']) - (values['aerobic_calories_avg'] * values['aerobic_calories_avg']))
			end
			if values['active_calories_cnt'] != 0
				values['active_calories_avg'] = values['active_calories_avg'] / values['active_calories_cnt']
				values['active_calories_std'] = Math.sqrt( (values['active_calories_std'] / values['active_calories_cnt']) - (values['active_calories_avg'] * values['active_calories_avg']))
			end
			if values['resting_calories_count'] != 0
				values['resting_calories_avg'] = values['resting_calories_avg'] / values['resting_calories_count']
				values['resting_calories_std'] = Math.sqrt( (values['resting_calories_std'] / values['resting_calories_count']) - (values['resting_calories_avg'] * values['resting_calories_avg']))
			end
			if values['total_calories_count'] != 0
				values['total_calories_avg'] = values['total_calories_avg'] / values['total_calories_count']
				values['total_calories_std'] = Math.sqrt( (values['total_calories_std'] / values['total_calories_count']) - (values['total_calories_avg'] * values['total_calories_avg']))
			end
			if values['weight_count'] != 0
				values['weight_avg'] = values['weight_avg'] / values['weight_count']
				values['weight_std'] = Math.sqrt( (values['weight_std'] / values['weight_count']) - (values['weight_avg'] * values['weight_avg']))
			end
			if values['steps_count'] != 0
				values['steps_avg'] = values['steps_avg'] / values['steps_count']
				values['steps_std'] = Math.sqrt( (values['steps_std'] / values['steps_count']) - (values['steps_avg'] * values['steps_avg']))
			end
			if values['flights_count'] != 0
				values['flights_avg'] = values['flights_avg'] / values['flights_count']
				values['flights_std'] = Math.sqrt( (values['flights_std'] / values['flights_count']) - (values['flights_avg'] * values['flights_avg']))
			end
			if values['miles_count'] != 0
				values['miles_avg'] = values['miles_avg'] / values['miles_count']
				values['miles_std'] = Math.sqrt( (values['miles_std'] / values['miles_count']) - (values['miles_avg'] * values['miles_avg']))
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
