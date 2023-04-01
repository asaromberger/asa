module IndividualHelper

    def info(individual, type)
		infos = Hash.new
		GenealogyInfo.where("genealogy_individual_id = ? AND itype = ?", individual.id, type).order('date').each do |info|
			infos[info.id] = Hash.new
			infos[info.id]['date'] = info.date
			infos[info.id]['place'] = info.place
			infos[info.id]['note'] = info.note
			if type == 'event'
				infos[info.id]['type'] = info.data['type']
				infos[info.id]['note'] = info.data['note']
			end
			infos[info.id]['sources'] = Hash.new
			GenealogyInfoSource.where("genealogy_info_id = ?", info.id).each do |src|
				infos[info.id]['sources'][src.id] = Hash.new
				infos[info.id]['sources'][src.id]['page'] = src.page
				infos[info.id]['sources'][src.id]['quay'] = src.quay
				infos[info.id]['sources'][src.id]['note'] = src.note
				if src.genealogy_source_id && src.genealogy_source_id > 0
					source = GenealogySource.find(src.genealogy_source_id)
					infos[info.id]['sources'][src.id]['source'] = "#{source.title} Published: #{source.published} REFN: #{source.refn}"
					if source.genealogy_repo_id && source.genealogy_repo_id > 0
						repo = GenealogyRepo.find(source.genealogy_repo_id)
						if ! repo.name.blank?
							infos[info.id]['sources'][src.id]['source'] = "#{infos[info.id]['sources'][src.id]['source']} Repo: #{repo.name}"
							if ! repo.city.blank?
								infos[info.id]['sources'][src.id]['source'] = "#{infos[info.id]['sources'][src.id]['source']} #{repo.city} #{repo.state} #{repo.country}"
							end
						end
					end
				else
					infos[info.id]['sources'][source.id]['source'] = ''
				end
			end
		end
		return(infos)
	end

end
