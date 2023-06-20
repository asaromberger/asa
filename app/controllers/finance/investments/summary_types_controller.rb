class Finance::Investments::SummaryTypesController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@title = 'Manage Summary Types'
		@summary_types = FinanceSummaryType.all.order('priority')
	end

	def show
		@summary_type = FinanceSummaryType.find(params[:id])
		@title = "Funds in #{@summary_type.stype}"
		@funds = Hash.new
		FinanceInvestmentsFund.all.order('fund').each do |fund|
			@funds[fund.id] = Hash.new
			fia = FinanceInvestmentsAccount.find(fund.finance_investments_account_id)
			@funds[fund.id]['name'] = "#{fia.name}: #{fund.fund}"
			@funds[fund.id]['included'] = false
		end
		FinanceInvestmentMap.where("finance_summary_type_id = ?", @summary_type.id).pluck('DISTINCT finance_investments_fund_id').each do |fund_id|
			@funds[fund_id]['included'] = true
		end
		@funds = @funds.sort_by { |id, values| values['name'].downcase }
	end

	def showupdate
		@summary_type = FinanceSummaryType.find(params[:summary_type])
		FinanceInvestmentsFund.all.each do |fund|
			investment_map = FinanceInvestmentMap.where("finance_summary_type_id = ? AND finance_investments_fund_id = ?", @summary_type.id, fund.id)
			if params[fund.id.to_s] == 'on'
				if investment_map.count == 0
					investment_map = FinanceInvestmentMap.new
					investment_map.finance_summary_type_id = @summary_type.id
					investment_map.finance_investments_fund_id = fund.id
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
