module GenealogyMarriedHelper

    def spouses
		spouses = []
		GenealogyIndividual.all.each do |individual|
			names = ''
			GenealogyInfo.where("genealogy_individual_id = ? AND itype = 'name'", individual.id).each do |name|
				if name.data['given']
					if name.data['surname']
						t = name.data['given'] + ' ' + name.data['surname'] + ' ' + name.data['suffix']
					else
						t = name.data['given']
					end
				elsif name.data['surname']
					t = name.data['surname']
				else
					t = ''
				end
				if names == ''
					names = t
				else
					names = names + ' OR ' + t
				end
			end
			spouses.push([names, individual.id])
		end
		return(spouses.sort_by { |name, id| name })
	end

end
