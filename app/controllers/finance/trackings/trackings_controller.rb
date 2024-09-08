class Finance::Trackings::TrackingsController < ApplicationController

	before_action :require_signed_in
	before_action :require_trackings

	def index
		@title = "Tracking Actions"
		@trackings = FinanceTracking.all.order('date, what')
		@today = Time.now.to_date
	end

	def show
		@tracking = FinanceTracking.find(params[:id])
		@results = Hash.new
		if @tracking.ptype == 'bill'
			@results['Date'] = @tracking.date
			@results['What'] = @tracking.what
			@results['Account'] = @tracking.from
			@results['Frequency'] = @tracking.inc
			@results['Note'] = @tracking.note
		elsif @tracking.ptype == 'cd'
			@results['Date'] = @tracking.date
			@results['What'] = @tracking.what
			@results['Value'] = precision(@tracking.amount, 2)
			@results['Rate'] = precision(@tracking.rate, 2)
			@results['In Account'] = @tracking.from
			@results['Note'] = @tracking.note
		elsif @tracking.ptype == 'transfer'
			@results['Date'] = @tracking.date
			@results['What'] = @tracking.what
			@results['Amount per month'] = precision(@tracking.amount, 2)
			@results['From'] = @tracking.from
			@results['To'] = @tracking.to
			@results['Remaining'] = precision(@tracking.remaining, 2)
			@results['Month Frequenty'] = @tracking.inc
			@results['Note'] = @tracking.note
		else
			fail
		end
	end

	def destroy
		@tracking = FinanceTracking.find(params[:id])
		if @tracking.ptype == 'bill'
			@tracking.date += (@tracking.inc).month
			@tracking.save
			redirect_to finance_trackings_trackings_path, notice: "#{@tracking.what} Updated"
		elsif @tracking.ptype == 'cd'
			if ! params[:value]
				redirect_to edit_finance_trackings_tracking_path(params[:id])
			else
				# add final value to fund
				@investment = FinanceInvestmentsInvestment.new
				@investment.finance_investments_fund_id = @tracking.finance_investments_fund_id
				@investment.date = @tracking.date
				@investment.value = @tracking.amount + params[:value].to_f
				@investment.save
				# set value to zero
				@investment = FinanceInvestmentsInvestment.new
				@investment.finance_investments_fund_id = @tracking.finance_investments_fund_id
				@investment.date = @tracking.date + 1.day
				@investment.value = 0
				@investment.save
				# mark cd closed
				@fund = FinanceInvestmentsFund.find(@tracking.finance_investments_fund_id)
				@fund.closed = true
				@fund.save
				@tracking.delete
				redirect_to finance_trackings_trackings_path, notice: "#{@tracking.what} Removed"
			end
		elsif @tracking.ptype == 'transfer'
			@tracking.date += (@tracking.inc).month
			@tracking.remaining -= @tracking.amount
			if @tracking.remaining > 0
				@tracking.save
				redirect_to finance_trackings_trackings_path, notice: "#{@tracking.what} Updated"
			else
				@tracking.delete
				redirect_to finance_trackings_trackings_path, notice: "#{@tracking.what} Removed"
			end
		else
			fail
		end
	end

	def edit
		@title = "Closing CD Value"
		@tracking = FinanceTracking.find(params[:id])
	end

private

	def require_trackings
		unless current_user_role('finance_trackings')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE TRACKINGS BILLS"
		end
	end

	def precision(value, precision)
		return( ((value * 10 ** precision).to_i).to_f / (10 ** precision))
	end

end
