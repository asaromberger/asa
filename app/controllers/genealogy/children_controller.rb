class Genealogy::ChildrenController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	include GenealogyChildHelper

	def new
		@title = "Add a Child"
		@child = GenealogyChild.new
		@individual = GenealogyIndividual.find(params[:individual_id].to_i)
		@families = families(@individual)
		@individuals = individuals()
	end

	def create
		@child = GenealogyChild.new
		@child.genealogy_individual_id = params[:child_id].to_i
		@child.genealogy_family_id = params[:family_id].to_i
		@child.save
		redirect_to edit_genealogy_individual_path(params[:genealogy_individual_id].to_i), notice: "Child added"
	end

	def edit
		@title = "Edit a Child"
		individual_id = params[:id].gsub(/:.*/, '').to_i
		child_id = params[:id].gsub(/.*:/, '').to_i
		@individual = GenealogyIndividual.find(individual_id)
		@child = GenealogyChild.find(child_id)
		@families = families(@individual)
		@individuals = individuals()
	end

	def update
		@individual = GenealogyIndividual.find(params[:individual_id].to_i)
		@child = GenealogyChild.find(params[:child_id].to_i)
		@child.genealogy_individual_id = params[:child_individual_id].to_i
		@child.genealogy_family_id = params[:family_id].to_i
		@child.save
		redirect_to edit_genealogy_individual_path(@individual.id), notice: "Child updated"
	end

	def destroy
		individual_id = params[:id].gsub(/:.*/, '').to_i
		child_id = params[:id].gsub(/.*:/, '').to_i
		@individual = GenealogyIndividual.find(individual_id)
		@child = GenealogyChild.find(child_id)
		redirect_to edit_genealogy_individual_path(individual_id), notice: "Child removed"
		@child.delete
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: GenealogyChildren"
		end
	end

end
