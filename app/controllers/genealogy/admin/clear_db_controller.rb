class Genealogy::Admin::ClearDbController < ApplicationController
	before_action :require_signed_in
	before_action :require_admin

	def new
		@title = "Clear Genealogy DB"
		@messages = []
		@messages.push("#{GenealogyChild.all.count} Children")
		@messages.push("#{GenealogyFamily.all.count} Families")
		@messages.push("#{GenealogyIndividual.all.count} Individuals")
		@messages.push("#{GenealogyInfo.all.count} Infos")
		@messages.push("#{GenealogyInfoSource.all.count} Info Sources")
		@messages.push("#{GenealogyRepo.all.count} Repos")
		@messages.push("#{GenealogySource.all.count} Sources")
	end

	def create
		GenealogyChild.all.delete_all
		GenealogyFamily.all.delete_all
		GenealogyIndividual.all.delete_all
		GenealogyInfo.all.delete_all
		GenealogyInfoSource.all.delete_all
		GenealogyRepo.all.delete_all
		GenealogySource.all.delete_all
		redirect_to genealogy_admin_display_index_path, notice: "Genealogy Database Cleared"
	end

	private

	def require_admin
		unless current_user_role('genealogy_admin')
			redirect_to root_url, alert: "Inadequate permissions: GENEALOGY ADMIN CLEAR DB"
		end
	end

end
