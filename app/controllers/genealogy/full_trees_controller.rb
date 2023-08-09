class Genealogy::FullTreesController < ApplicationController

	before_action :require_signed_in
	before_action :require_genealogy

	def index
		@title = "Full Trees"
		indis = Hash.new
		individuals = Hash.new
		GenealogyIndividual.all.each do |indi|
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", indi.id).each do |info|
				if individuals[indi.id]
					individuals[indi.id] += ", #{info.data['given']} #{info.data['surname']} #{info.data['suffix']}"
				else
					individuals[indi.id] = "#{info.data['given']} #{info.data['surname']} #{info.data['suffix']}"
				end
			end
			indis[indi.id] = indi
		end
		@trees = Hash.new
		while indis.count > 0
			id, indi = indis.first
			list = [indi.id]
			@trees[indi.id] = []
lcnt = 0
			while list.count > 0
lcnt += 1
				id = list.pop
				@trees[indi.id].push(individuals[id])
				indis.delete(id)
				GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", id, id).each do |family|
					if indis[family.genealogy_husband_id]
						list.push(family.genealogy_husband_id)
						#@trees[indi.id].push(individuals[family.genealogy_husband_id])
						indis.delete(family.genealogy_husband_id)
					end
					if indis[family.genealogy_wife_id]
						list.push(family.genealogy_wife_id)
						#@trees[indi.id].push(individuals[family.genealogy_wife_id])
						indis.delete(family.genealogy_wife_id)
					end
					GenealogyChild.where("genealogy_family_id = ?", family.id).each do |child|
						if indis[child.genealogy_individual_id]
							list.push(child.genealogy_individual_id)
							#@trees[indi.id].push(individuals[child.genealogy_individual_id])
							indis.delete(child.genealogy_individual_id)
						end
					end
				end
				GenealogyChild.where("genealogy_individual_id = ?", id).each do |child|
					family = GenealogyFamily.find(child.genealogy_family_id)
					if indis[family.genealogy_husband_id]
						list.push(family.genealogy_husband_id)
						#@trees[indi.id].push(individuals[family.genealogy_husband_id])
						indis.delete(family.genealogy_husband_id)
					end
					if indis[family.genealogy_wife_id]
						list.push(family.genealogy_wife_id)
						#@trees[indi.id].push(individuals[family.genealogy_wife_id])
						indis.delete(family.genealogy_wife_id)
					end
				end
			end
@trees[indi.id].push("LCNT #{lcnt}")
		end
	end

	private

	def require_genealogy
		unless current_user_role('genealogy')
			redirect_to root_url, alert: "Inadequate permissions: Genealogy Tree"
		end
	end

end
