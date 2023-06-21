class Finance::Investments::InvestmentsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@title = "#{@account.name} Funds"
		@funds = Hash.new
		@errors = params[:errors]
		@exists = params[:exists]
		if @status == 'open'
			funds = FinanceInvestmentsFund.where('finance_investments_account_id = ? AND (closed IS NULL OR closed != true)', @account.id).order('fund')
		elsif @status == 'closed'
			funds = FinanceInvestmentsFund.where('finance_investments_account_id = ? AND closed = true', @account.id).order('fund')
		else
			funds = FinanceInvestmentsFund.where('finance_investments_account_id = ?', @account.id).order('fund')
		end
		@total = 0
		funds.each do |fund|
			@funds[fund.id] = Hash.new
			@funds[fund.id]['fund'] = "#{@account.name}: #{fund.fund}"
			@funds[fund.id]['type'] = fund.atype
			investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", fund.id).order('date DESC')
			if investment.count > 0
				investment = investment.first
				@funds[fund.id]['date'] = investment.date
				@funds[fund.id]['value'] = investment.value
				@total += investment.value
			else
				@funds[fund.id]['date'] = ''
				@funds[fund.id]['value'] = 0
			end
			@funds[fund.id]['closed'] = fund.closed
		end
		@funds = @funds.sort_by { |id, values| values['fund'].downcase }
	end

	def show
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:id])
		@title = "#{@fund.fund}"
		if @fund.atype == 'cash'
			@headers = []
		elsif @fund.atype == 'brokerage'
			@headers = ['Shares', 'Per Share']
		elsif @fund.atype == 'annuity'
			@headers = ['Guaranteed', 'Yearly']
		end
		@errors = params[:errors]
		@exists = params[:exists]
		@investments = Hash.new
		FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", @fund.id).order('date DESC').each do |investment|
			@investments[investment.id] = Hash.new
			@investments[investment.id]['date'] = investment.date
			@investments[investment.id]['value'] = investment.value
			if @fund.atype == 'cash'
			elsif @fund.atype == 'brokerage'
				@investments[investment.id]['Shares'] = investment.shares
				@investments[investment.id]['Per Share'] = investment.pershare
			elsif @fund.atype == 'annuity'
				@investments[investment.id]['Guaranteed'] = investment.guaranteed
				@investments[investment.id]['Yearly'] = investment.guaranteed * 0.05
			end
		end
	end

	def new
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:id])
		@title = "New Entry for #{@fund.fund}"
		@investment = FinanceInvestmentsInvestment.new
		if session['investmentdate'].blank?
			@investment.date = (Time.now - 1.month).end_of_month.to_date
		else
			@investment.date = session['investmentdate']
		end
		lastinvestment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", @fund.id).order('date DESC').first
		if @fund.atype == 'cash'
			@headers = ['value']
			if lastinvestment.blank?
				@investment.value = 0
			else
				@investment.value = lastinvestment.value
			end
		elsif @fund.atype == 'brokerage'
			@headers = ['shares', 'pershare']
			if lastinvestment.blank?
				@investment.shares = 0
				@investment.pershare = 0
			else
				@investment.shares = lastinvestment.shares
				@investment.pershare = lastinvestment.pershare
			end
		elsif @fund.atype == 'annuity'
			@headers = ['value', 'guaranteed']
			if lastinvestment.blank?
				@investment.value = 0
				@investment.guaranteed = 0
			else
				@investment.value = lastinvestment.value
				@investment.guaranteed = lastinvestment.guaranteed
			end
		end
	end

	def create
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:fund])
		@investment = FinanceInvestmentsInvestment.new(investment_params)
		@investment.finance_investments_fund_id = @fund.id
		if @fund.atype == 'brokerage'
			@investment.value = @investment.shares * @investment.pershare
		end
		session['investmentdate'] = @investment.date
		if @investment.save
			redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: 'Item Added'
		else
			redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: 'Failed to create Item'
		end
	end

	def edit
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:fund])
		@title = "Edit Entry for #{@fund.fund}"
		@investment = FinanceInvestmentsInvestment.find(params[:id])
		if @fund.atype == 'cash'
			@headers = ['value']
		elsif @fund.atype == 'brokerage'
			@headers = ['shares', 'pershare']
		elsif @fund.atype == 'annuity'
			@headers = ['value', 'guaranteed']
		end
	end

	def update
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@fund = FinanceInvestmentsFund.find(params[:fund])
		@investment = FinanceInvestmentsInvestment.find(params[:id])
		if @fund.atype == 'brokerage'
			params[:finance_investment][:value] = params[:finance_investment][:shares].to_f * params[:finance_investment][:pershare].to_f
		end
		session['investmentdate'] = @investment.date
		if @investment.update(investment_params)
			redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: 'Item Updated'
		else
			redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), alert: 'Failed to update Item'
		end
	end

	def destroy
		@status = params[:status]
		@account = FinanceInvestmentsAccount.find(params[:account_id])
		@investment = FinanceInvestmentsInvestment.find(params[:id])
		@investment.delete
		redirect_to finance_investments_investments_path(status: @status, account_id: @account.id), notice: "Item Deleted"
	end

private
	
	def investment_params
		params.require(:finance_investments_investment).permit(:date, :value, :shares, :pershare, :guaranteed)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS INVESTMENTS"
		end
	end

end
