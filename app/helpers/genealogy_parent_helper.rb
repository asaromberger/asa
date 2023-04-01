module GenealogyParentHelper

    def families
		families = []
		GenealogyFamily.all.each do |family|
			fathernames = ''
			if ! family.genealogy_husband_id.blank?
				father = GenealogyIndividual.find(family.genealogy_husband_id)
				GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", father.id).each do |name|
						if name.data['given']
						else
							name.data['given'] = 'NULL'
						end
						if name.data['surname']
						else
							name.data['surname'] = 'NULL'
						end
						if name.data['suffix']
						else
							name.data['surname'] = ''
						end
					if fathernames == ''
						fathernames = name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['suffix']
					else
						fathernames = fathernames + ' OR ' + name.data['given'] + name.data['surname'] + ' ' + name.data['suffix']
					end
				end
			end
			mothernames = ''
			if ! family.genealogy_wife_id.blank?
				mother = GenealogyIndividual.find(family.genealogy_wife_id)
				GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", mother.id).each do |name|
						if name.data['given']
						else
							name.data['given'] = 'NULL'
						end
						if name.data['surname']
						else
							name.data['surname'] = 'NULL'
						end
						if name.data['suffix']
						else
							name.data['suffix'] = ''
						end
					if mothernames == ''
						mothernames = name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['suffix']
					else
						mothernames = mothernames + ' OR ' + name.data['given'] + name.data['surname'] + ' ' + name.data['suffix']
					end
				end
			end
			names = fathernames
			if mothernames != ''
				if names == ''
					names = mothernames
				else
					names = fathernames + ' AND ' + mothernames
				end
			end
			families.push([names, family.id])
		end
		return(families.sort_by { |name, id| name })
	end

end
