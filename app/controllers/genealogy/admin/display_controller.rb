class Genealogy::Admin::DisplayController < ApplicationController
	before_action :require_signed_in
	before_action :require_genealogy_admin

	include GenealogyDisplayHelper

	def index
		@title = "Genealogy Display"
		@individuals = Hash.new
		GenealogyIndividual.all.order('id').each do |individual|
			@individuals[individual.id] = Hash.new
			@individuals[individual.id]['uid'] = individual.uid
			@individuals[individual.id]['refn'] = individual.refn
			@individuals[individual.id]['sex'] = individual.sex
			@individuals[individual.id]['updated'] = individual.updated
			@individuals[individual.id]['married'] = []
			@individuals[individual.id]['parent'] = []
			@individuals[individual.id]['children'] = []

			@individuals[individual.id]['name'] = display(individual, 'name')

			@individuals[individual.id]['birth'] = display(individual, 'birth')

			@individuals[individual.id]['death'] = display(individual, 'death')

			@individuals[individual.id]['burried'] = display(individual, 'burried')

			@individuals[individual.id]['residence'] = display(individual, 'residence')

			@individuals[individual.id]['occupation'] = display(individual, 'occupation')

			@individuals[individual.id]['event'] = display(individual, 'event')

			@individuals[individual.id]['baptism'] = display(individual, 'baptism')

			@individuals[individual.id]['census'] = display(individual, 'census')
		end

		GenealogyIndividual.all.order('id').each do |individual|
			GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", individual.id, individual.id).each do |family|
				if family.genealogy_husband_id == individual.id
					if @individuals.key?(family.genealogy_wife_id)
						@individuals[individual.id]['married'].push("#{@individuals[family.genealogy_wife_id]['name']}")
					else
						@individuals[individual.id]['married'].push("UNKNOWN")
					end
				else
					if @individuals.key?(family.genealogy_husband_id)
						@individuals[individual.id]['married'].push("#{@individuals[family.genealogy_husband_id]['name']}")
					else
						@individuals[individual.id]['married'].push("UNKNOWN")
					end
				end
			end
			GenealogyChild.where("genealogy_individual_id = ?", individual.id).each do |child|
				family = GenealogyFamily.find(child.genealogy_family_id)
				if @individuals.key?(family.genealogy_husband_id)
					@individuals[individual.id]['parent'].push("#{@individuals[family.genealogy_husband_id]['name']}")
				end
				if @individuals.key?(family.genealogy_wife_id)
					@individuals[individual.id]['parent'].push("#{@individuals[family.genealogy_wife_id]['name']}")
				end
			end
			familyids = GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", individual.id, individual.id).pluck("DISTINCT id")
			GenealogyChild.where("genealogy_family_id IN (?)", familyids).each do |child|
				if @individuals.key?(child.genealogy_individual_id)
					@individuals[individual.id]['children'].push("#{@individuals[child.genealogy_individual_id]['name']}")
				else
					@individuals[individual.id]['children'].push("UNKNOWN #{child.genealogy_individual_id}")
				end
			end
		end
	end

	private

	def require_genealogy_admin
		unless current_user_role('genealogy_admin')
			redirect_to root_url, alert: "Inadequate permissions: Genealogy Admin Display"
		end
	end

end
