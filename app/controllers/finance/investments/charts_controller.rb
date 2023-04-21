class Finance::Investments::ChartsController < ApplicationController

	before_action :require_signed_in
	before_action :require_investments

	def index
		@fromyear = params[:fromyear]
		@toyear = params[:toyear]
		@years = []
		(@fromyear..@toyear).each do |year|
			@years.push(year.to_i)
		end
		@summaries = Hash.new
		FinanceSummaryType.all.order('priority').each do |summary|
			@summaries[summary.id] = Hash.new
			@summaries[summary.id]['name'] = summary.stype
			@summaries[summary.id]['priority'] = summary.priority
			@years.each do |year|
				@summaries[summary.id][year] = 0
			end
			FinanceInvestmentMap.where("finance_summary_type_id = ?", summary.id).each do |map|
				t = Hash.new
				FinanceInvestment.where("finance_account_id = ? AND EXTRACT(year FROM date) >= ? AND EXTRACT(year FROM date) <= ?", map.finance_account_id, @fromyear, @toyear).order('date').each do |investment|
					t[investment.date.year] = investment.value
				end
				@years.each do |year|
					if t[year]
						@summaries[summary.id][year] = @summaries[summary.id][year] + t[year]
					elsif t[year - 1]
						@summaries[summary.id][year] = @summaries[summary.id][year] + t[year - 1]
					end
				end
			end
		end
	end

private

	def require_investments
		unless current_user_role('finance_investments')
			redirect_to users_path, alert: "Inadequate permissions: FINANCE INVESTMENTS CHARTS"
		end
	end

end
