class Genealogy::MarriedsController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy

	include GenealogyMarriedHelper

	def new
		@title = "Add a Spouse"
		@individual = GenealogyIndividual.find(params[:individual_id].to_i)
		@spouses = spouses()
	end

	def create
		@individual = GenealogyIndividual.find(params[:individual_id].to_i)
		spouse_id = params[:spouse_id].to_i
		if GenealogyFamily.where("(genealogy_husband_id = ? AND genealogy_wife_id = ?) OR (genealogy_wife_id = ? and genealogy_husband_id = ?)", @individual.id, spouse_id, @individual.id, spouse_id).count > 0
			redirect_to edit_genealogy_individual_path(@individual.id), notice: "Spouse already exists"
			return
		end
		@family = GenealogyFamily.new
		if @individual.sex == 'M'
			@family.genealogy_husband_id = @individual.id
			@family.genealogy_wife_id = params[:spouse_id].to_i
		else
			@family.genealogy_wife_id = @individual.id
			@family.genealogy_husband_id = params[:spouse_id].to_i
		end
		@family.save
		redirect_to edit_genealogy_individual_path(@individual.id), notice: "Spouse added"
	end

	def edit
		@title = "Edit a Spouse"
		individual_id = params[:id].gsub(/:.*/, '').to_i
		family_id = params[:id].gsub(/.*:/, '').to_i
		@individual = GenealogyIndividual.find(individual_id)
		@family = GenealogyFamily.find(family_id)
		if @family.genealogy_husband_id = @individual.id
			@spouse = GenealogyIndividual.find(@family.genealogy_wife_id)
		else
			@spouse = GenealogyIndividual.find(@family.genealogy_husband_id)
		end
		@spouses = spouses()
	end

	def update
		@individual = GenealogyIndividual.find(params[:individual_id].to_i)
		@family = GenealogyFamily.find(params[:family_id].to_i)
		spouse_id = params[:spouse_id].to_i
		if GenealogyFamily.where("(genealogy_husband_id = ? AND genealogy_wife_id = ?) OR (genealogy_wife_id = ? and genealogy_husband_id = ?)", @individual.id, spouse_id, @individual.id, spouse_id).count > 0
			redirect_to edit_genealogy_individual_path(@individual.id), notice: "Spouse already exists"
			return
		end
		if @family.genealogy_husband_id == @individual.id
			@family.genealogy_wife_id = spouse_id
		else
			@family.genealogy_husband_id = spouse_id
		end
		@family.save
		redirect_to edit_genealogy_individual_path(@individual.id), notice: "Spouse updated"
	end

	def destroy
		individual_id = params[:id].gsub(/:.*/, '').to_i
		family_id = params[:id].gsub(/.*:/, '').to_i
		family = GenealogyFamily.find(family_id)
		if GenealogyChild.where("genealogy_family_id = ?", family.id).count > 0
			redirect_to edit_genealogy_individual_path(individual_id), alert: "In use for a child"
		else
			redirect_to edit_genealogy_individual_path(individual_id), notice: "Spouse removed"
			family.delete
		end
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Gen Display"
		end
	end

end
