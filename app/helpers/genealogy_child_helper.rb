module GenealogyChildHelper

    def families(individual)
		families = []
		GenealogyFamily.where("genealogy_husband_id = ? OR genealogy_wife_id = ?", individual.id, individual.id).each do |family|
			hname = ''
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", family.genealogy_husband_id).each do |name|
				if hname == ''
					hname = name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['surname']
				else
					hname = hname + ' OR ' + name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['surname']
				end
			end
			wname = ''
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", family.genealogy_wife_id).each do |name|
				if wname == ''
					wname = name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['surname']
				else
					wname = wname + ' OR ' + name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['surname']
				end
			end
			if hname == ''
				name = wname
			elsif wname == ''
				name = hname
			else
				name = hname + ' AND ' + wname
			end
			families.push([name, family.id])
		end
		return(families)
	end

	def individuals
		individuals = []
		GenealogyIndividual.all.each do |individual|
			names = ''
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
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
				if names == ''
					names = name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['suffix']
				else
					names = names + ' OR ' + name.data['given'] + name.data['surname'] + ' ' + name.data['suffix']
				end
			end
			individuals.push([names, individual.id])
		end
		return(individuals.sort_by { |name, id| name })
	end

end
