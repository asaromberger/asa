class Genealogy::ParentsController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	include GenealogyParentHelper

	def new
		@title = "Add a Parent"
		@child = GenealogyChild.new
		@individual = GenealogyIndividual.find(params[:individual_id].to_i)
		@child.genealogy_individual_id = @individual.id
		@families = families()
	end

	def create
		@child = GenealogyChild.new
		@child.genealogy_individual_id = params[:individual_id].to_i
		@child.genealogy_family_id = params[:family_id].to_i
		@child.save
		redirect_to edit_genealogy_individual_path(@child.genealogy_individual_id), notice: "Parents added"
	end

	def edit
		@title = "Edit a Parent"
		@individual = GenealogyIndividual.find(params[:individual_id])
		@child = GenealogyChild.find(params[:id])
		@families = families()
	end

	def update
		@child = GenealogyChild.find(params[:id])
		@child.genealogy_family_id = params[:family_id].to_i
		@child.save
		redirect_to edit_genealogy_individual_path(@child.genealogy_individual_id), notice: "Parents updated"
	end

	def destroy
		@parent = GenealogyChild.find(params[:id])
		redirect_to edit_genealogy_individual_path(@parent.genealogy_individual_id), notice: "Parents removed"
		@parent.delete
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

end
