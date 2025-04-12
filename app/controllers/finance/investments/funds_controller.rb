class Finance::Investments::FundsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def new
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@title = 'New Fund'
		@fund = FinanceInvestmentsFund.new
		@fund.finance_investments_account_id = @account.id
		@atypes = [['cash'], ['brokerage'], ['annuity']]
		@accounts = FinanceInvestmentsAccount.all.order('name')
	end

	def create
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		if FinanceInvestmentsFund.where("fund = ? AND finance_investments_account_id = ?", params[:finance_investments_fund][:fund], params[:finance_investments_fund][:finance_investments_account_id].to_i).count > 0
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: 'Fund already exists'
		else
			@fund = FinanceInvestmentsFund.new(fund_params)
			if @fund.save
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: 'Fund Added'
			else
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: 'Failed to create Fund'
			end
		end
	end

	def edit
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@title = 'Edit Fund'
		@fund = FinanceInvestmentsFund.find(params[:id])
		@atypes = [['cash'], ['brokerage'], ['annuity']]
		@accounts = FinanceInvestmentsAccount.all.order('name')
	end

	def update
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		fa = FinanceInvestmentsFund.where("fund = ? AND finance_investments_account_id = ?", params[:finance_investments_fund][:fund], params[:finance_investments_fund][:finance_investments_account_id].to_i).first
		if fa && fa.id != params[:id].to_i
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: 'Fund already exists'
		else
			@fund = FinanceInvestmentsFund.find(params[:id])
			if @fund.update(fund_params)
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: 'Fund Updated'
			else
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: 'Failed to update Fund'
			end
		end
	end

	def show
		@status = params[:status]
		@fund = FinanceInvestmentsFund.find(params[:id])
		@title = @fund.fund
		@summary = Hash.new
		FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", @fund.id).order('date').each do |investment|
			y = investment.date.year
			m = investment.date.month
			if m < 10
				m = "0#{m}"
			end
			ym = "#{y}-#{m}"
			@year = investment.date.year
			@month = investment.date.month
			@summary[ym] = investment.value
		end
	end

	def destroy
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:id])
		FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", @fund.id).delete_all
		FinanceInvestmentsRebalance.where("finance_investments_fund_id = ?", @fund.id).delete_all
		@fund.delete
		redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: "Fund #{@fund.fund} Deleted"
	end

	def close
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:id])
		investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", @fund.id).order('date DESC')
		if investment.count > 0
			investment = investment.first
			if investment.value != 0
				redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: "Fund #{@account.name} #{@fund.fund} has a non-zero value and cannot be closed"
				return
			end
		end
		@fund.closed = true
		@fund.save
		redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: "Fund #{@account.name} #{@fund.fund} Closed"
	end

	def reopen
		@fund = FinanceInvestmentsFund.find(params[:id])
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund.closed = false
		@fund.save
		redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: "Fund #{@account.name} #{@fund.fund} Reopened"
	end

private
	
	def fund_params
		params.require(:finance_investments_fund).permit(:fund, :atype, :finance_investments_account_id)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS FUNDS"
		end
	end

end
