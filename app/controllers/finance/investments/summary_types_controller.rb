class Finance::Investments::SummaryTypesController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Manage Summary Types'
		@summary_types = FinanceSummaryType.all.order('priority')
	end

	def show
		@summary_type = FinanceSummaryType.find(params[:id])
		@title = "Accounts in #{@summary_type.stype}"
		@accounts = Hash.new
		FinanceAccount.all.order('account').each do |account|
			@accounts[account.id] = Hash.new
			@accounts[account.id]['name'] = account.account
			@accounts[account.id]['included'] = false
		end
		FinanceInvestmentMap.where("finance_summary_type_id = ?", @summary_type.id).pluck('DISTINCT finance_account_id').each do |account_id|
			@accounts[account_id]['included'] = true
		end
	end

	def showupdate
		@summary_type = FinanceSummaryType.find(params[:summary_type])
		FinanceAccount.all.each do |account|
			investment_map = FinanceInvestmentMap.where("finance_summary_type_id = ? AND finance_account_id = ?", @summary_type.id, account.id)
			if params[account.id.to_s] == 'on'
				if investment_map.count == 0
					investment_map = FinanceInvestmentMap.new
					investment_map.finance_summary_type_id = @summary_type.id
					investment_map.finance_account_id = account.id
					investment_map.save
				end
			else
				if investment_map.count > 0
					investment_map.first.delete
				end
			end
		end
		redirect_to finance_investments_summary_types_path, notice: "#{@summary_type.stype} updated"
	end

	def new
		@title = 'New Summary Type'
		@summary_type = FinanceSummaryType.new
	end

	def create
		if FinanceSummaryType.where("stype = ?", params[:finance_summary_type][:stype]).count > 0
			redirect_to finance_investments_summary_types_path, alert: 'Summary Type already exists'
		else
			@summary_type = FinanceSummaryType.new(summary_type_params)
			if @summary_type.save
				redirect_to finance_investments_summary_types_path, notice: 'Summary Type Added'
			else
				redirect_to finance_investments_summary_types_path, alert: 'Failed to create Summary Type'
			end
		end
	end

	def edit
		@title = 'Edit Summary Type'
		@summary_type = FinanceSummaryType.find(params[:id])
	end

	def update
		@summary_type = FinanceSummaryType.find(params[:id])
		if @summary_type.update(summary_type_params)
			redirect_to finance_investments_summary_types_path, notice: 'Summary Type Updated'
		else
			redirect_to finance_investments_summary_types_path, alert: 'Failed to update Summary Type'
		end
	end

	def destroy
		@summary_type = FinanceSummaryType.find(params[:id])
		FinanceInvestmentMap.where("finance_summary_type_id = ?", @summary_type.id).delete_all
		@summary_type.delete
			redirect_to finance_investments_summary_types_path, notice: "Summary Type #{@summary_type.stype} Deleted"
	end

private
	
	def summary_type_params
		params.require(:finance_summary_type).permit(:stype, :priority)
	end

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS SUMMARYTYPES"
		end
	end

end
