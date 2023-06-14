class Finance::Payments::CurrentController < ApplicationController

	before_action :require_signed_in
	before_action :require_payments

	def index
		@title = "Current Actions"
		@currents = FinancePayment.all.order('date')
		@today = Time.now.to_date
	end

	def show
		@current = FinancePayment.find(params[:id])
		@results = Hash.new
		if @current.ptype == 'bill'
			@results['Date'] = @current.date
			@results['What'] = @current.what
			@results['Account'] = @current.from
			@results['Frequency'] = @current.inc
			@results['Note'] = @current.note
		elsif @current.ptype == 'cd'
			@results['Date'] = @current.date
			@results['What'] = @current.what
			@results['Value'] = precision(@current.amount, 2)
			@results['Rate'] = precision(@current.rate, 2)
			@results['In Account'] = @current.from
			@results['Note'] = @current.note
		elsif @current.ptype == 'transfer'
			@results['Date'] = @current.date
			@results['What'] = @current.what
			@results['Amount per month'] = precision(@current.amount, 2)
			@results['From'] = @current.from
			@results['To'] = @current.to
			@results['Remaining'] = precision(@current.remaining, 2)
			@results['Month Frequenty'] = @current.inc
			@results['Note'] = @current.note
		else
			fail
		end
	end

	def destroy
		@current = FinancePayment.find(params[:id])
		if @current.ptype == 'bill'
			@current.date += (@current.inc).month
			@current.save
			redirect_to finance_payments_current_index_path, notice: "#{@current.what} Updated"
		elsif @current.ptype == 'cd'
			@current.delete
			redirect_to finance_payments_current_index_path, notice: "#{@current.what} Removed"
		elsif @current.ptype == 'transfer'
			@current.date += (@current.inc).month
			@current.remaining -= @current.amount
			if @current.remaining > 0
				@current.save
				redirect_to finance_payments_current_index_path, notice: "#{@current.what} Updated"
			else
				@current.delete
				redirect_to finance_payments_current_index_path, notice: "#{@current.what} Removed"
			end
		else
			fail
		end
	end

private

	def require_payments
		unless current_user_role('finance_payments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE PAYMENTS BILLS"
		end
	end

	def precision(value, precision)
		return( ((value * 10 ** precision).to_i).to_f / (10 ** precision))
	end

end
