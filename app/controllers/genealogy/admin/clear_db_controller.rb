class Genealogy::Admin::ClearDbController < ApplicationController
	before_action :require_signed_in
	before_action :require_admin

	def new
		@title = "Clear Genealogy DB"
	end

	def create
		GenealogyChild.all.delete_all
		GenealogyFamily.all.delete_all
		GenealogyIndividual.all.delete_all
		GenealogyInfo.all.delete_all
		GenealogyInfoSource.all.delete_all
		GenealogyRepo.all.delete_all
		GenealogySource.all.delete_all
		redirect_to genealogy_admin_clear_db_index_path, notice: "Genealogy Database Cleared"
	end

	private

	def require_admin
		unless current_user_role('genealogy_admin')
			redirect_to root_url, alert: "Inadequate permissions: GENEALOGY ADMIN CLEAR DB"
		end
	end

end
