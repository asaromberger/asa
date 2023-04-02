module GenealogyTreeHelper

    def tree(tree, family_ids)
		GenealogyChild.where("genealogy_family_id IN (?)", family_ids).each do |child|
			individual = GenealogyIndividual.find(child.genealogy_individual_id)
			tree[individual.id] = Hash.new
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
				if tree[individual.id]['name'].blank?
					tree[individual.id]['name'] = "#{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				else
					tree[individual.id]['name'] = "#{tree[individual.id]['name']} OR #{name.data['given']} #{name.data['surname']} #{name.data['suffix']}"
				end
			end
			tree[individual.id]['tree'] = Hash.new
			tree(tree[individual.id]['tree'], GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", individual.id, individual.id).pluck('DISTINCT id'))
		end
	end

end
