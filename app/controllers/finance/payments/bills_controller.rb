class Finance::Payments::BillsController < ApplicationController

	before_action :require_signed_in
	before_action :require_payments

	def index
		@title = "Bills"
		@bills = FinancePayment.where("ptype = 'bill'").order('date')
	end

	def new
		@title = 'New Bill'
		@bill = FinancePayment.new
		@bill.date = Time.now.to_date
		@bill.ptype = 'bill'
		@bill.inc = 1
	end

	def create
		@bill = FinancePayment.new(bill_params)
		if @bill.save
			redirect_to finance_payments_bills_path, notice: 'Bill Added'
		else
			redirect_to finance_payments_bills_path, alert: 'Failed to create Bill'
		end
	end

	def edit
		@title = 'Edit Bill'
		@bill = FinancePayment.find(params[:id])
	end

	def update
		@bill = FinancePayment.find(params[:id])
		if @bill.update(bill_params)
			redirect_to finance_payments_bills_path, notice: 'Bill Updated'
		else
			redirect_to finance_payments_bills_path, alert: 'Failed to update Bill'
		end
	end

	def destroy
		@bill = FinancePayment.find(params[:id])
		@bill.delete
		redirect_to finance_payments_bills_path, notice: "Bill Deleted"
	end

private
	
	def bill_params
		params.require(:finance_payment).permit(:ptype, :date, :what, :amount, :from, :inc, :note)
	end

	def require_payments
		unless current_user_role('finance_payments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE PAYMENTS BILLS"
		end
	end

end
