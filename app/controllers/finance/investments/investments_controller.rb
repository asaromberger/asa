class Finance::Investments::InvestmentsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@status = params[:status]
		@title = 'Funds'
		accounts = Hash.new
		FinanceInvestmentsAccount.all.each do |account|
			accounts[account.id] = account.name
		end
		@funds = Hash.new
		@errors = params[:errors]
		@exists = params[:exists]
		if @status == 'open'
			funds = FinanceInvestmentsFund.where('closed is NULL or closed = false').order('fund')
		elsif @status == 'closed'
			funds = FinanceInvestmentsFund.where('closed = true').order('fund')
		else
			funds = FinanceInvestmentsFund.all.order('fund')
		end
		funds.each do |fund|
			@funds[fund.id] = Hash.new
			@funds[fund.id]['fund'] = "#{accounts[fund.finance_investments_account_id]}: #{fund.fund}"
			@funds[fund.id]['type'] = fund.atype
			investment = FinanceInvestmentsInvestment.where("finance_investments_fund_id = ?", fund.id).order('date DESC')
			if investment.count > 0
				@funds[fund.id]['date'] = investment.first.date
				@funds[fund.id]['value'] = investment.first.value
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
		@fund = FinanceInvestmentsFund.find(params[:fund])
		@investment = FinanceInvestmentsInvestment.new(investment_params)
		@investment.finance_investments_fund_id = @fund.id
		if @fund.atype == 'brokerage'
			@investment.value = @investment.shares * @investment.pershare
		end
		session['investmentdate'] = @investment.date
		if @investment.save
			redirect_to finance_investments_investments_path(status: @status), notice: 'Item Added'
		else
			redirect_to finance_investments_investments_path(status: @status), alert: 'Failed to create Item'
		end
	end

	def edit
		@status = params[:status]
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
		@fund = FinanceInvestmentsFund.find(params[:fund])
		@investment = FinanceInvestmentsInvestment.find(params[:id])
		if @fund.atype == 'brokerage'
			params[:finance_investment][:value] = params[:finance_investment][:shares].to_f * params[:finance_investment][:pershare].to_f
		end
		session['investmentdate'] = @investment.date
		if @investment.update(investment_params)
			redirect_to finance_investments_investments_path(status: @status), notice: 'Item Updated'
		else
			redirect_to finance_investments_investments_path(status: @status), alert: 'Failed to update Item'
		end
	end

	def destroy
		@status = params[:status]
		@investment = FinanceInvestmentsInvestment.find(params[:id])
		@investment.delete
		redirect_to finance_investments_investments_path(status: @status), notice: "Item Deleted"
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
