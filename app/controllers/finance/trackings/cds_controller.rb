class Finance::Trackings::CdsController < ApplicationController

	before_action :require_signed_in
	before_action :require_trackings

	def index
		@title = "CDs"
		@cds = FinanceTracking.where("ptype = 'cd'").order('date, what')
	end

	def new
		@title = 'New CD'
		@cd = FinanceTracking.new
		@cd.date = Time.now.to_date
		@cd.ptype = 'cd'
		@cd.inc = 1
		@accounts = FinanceInvestmentsAccount.all.order('name')
	end

	def create
		@cd = FinanceTracking.new(cd_params)
		@cd.to = @cd.finance_investments_account.name
		if @cd.save
			redirect_to finance_trackings_cds_path, notice: 'CD Added'
		else
			redirect_to finance_trackings_cds_path, alert: 'Failed to create CD'
		end
		# add cd to fund
		@fund = FinanceInvestmentsFund.new
		@fund.fund = @cd.what
		@fund.atype = 'cash'
		@fund.closed = false
		@fund.finance_investments_account_id = @cd.finance_investments_account_id
		@fund.save
		@cd.finance_investments_fund_id = @fund.id
		@cd.save
		@investment = FinanceInvestmentsInvestment.new
		@investment.finance_investments_fund_id = @fund.id
		@investment.date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date
		@investment.value = @cd.amount
		@investment.save
	end

	def edit
		@title = 'Edit CD'
		@cd = FinanceTracking.find(params[:id])
		@accounts = FinanceInvestmentsAccount.all.order('name')
		if ! @cd.finance_investments_fund_id
			@funds = FinanceInvestmentsFund.where("finance_investments_account_id = ?", @cd.finance_investments_account_id).order('fund')
		end
	end

	def update
		@cd = FinanceTracking.find(params[:id])
		@cd.to = FinanceInvestmentsAccount.find(params[:finance_tracking][:finance_investments_account_id].to_i).name
		if @cd.update(cd_params)
			redirect_to finance_trackings_cds_path, notice: 'CD Updated'
		else
			redirect_to finance_trackings_cds_path, alert: 'Failed to update CD'
		end
	end

	def destroy
		@cd = FinanceTracking.find(params[:id])
		@cd.delete
		redirect_to finance_trackings_cds_path, notice: "CD Deleted"
	end

private
	
	def cd_params
		params.require(:finance_tracking).permit(:ptype, :date, :what, :amount, :rate, :to, :finance_investments_account_id, :finance_investments_fund_id, :note)
	end

	def require_trackings
		unless current_user_role('finance_trackings')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE TRACKINGS CD"
		end
	end

end
