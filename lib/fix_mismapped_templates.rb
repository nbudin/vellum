Project.all.each do |p|
  p.maps.all.each do |m|
    m.mapped_doc_templates.each do |mdt|
      if mdt.doc_template.nil?
        puts "#{m.name} in #{p.name} has unmapped doc template #{mdt.id}"
      elsif mdt.doc_template.project != p
        puts "#{mdt.doc_template.name} in #{p.name} -> #{m.name} is mismapped"
        good_template = p.doc_templates.first(:conditions => 
                                              {:name => mdt.doc_template.name})
        if good_template
          puts "Will remap using template #{good_template.id}"
          mdt.doc_template = good_template
          mdt.save!
        else
          puts "!!! Cannot find template to remap with!"
        end
      end
    end
    m.mapped_relationship_types.each do |mrt|
      if mrt.relationship_type.nil?
        puts "#{m.name} in #{p.name} has unmapped relationship type #{mrt.id}"
      elsif mrt.relationship_type.project != p
        puts "#{mrt.relationship_type.left_name} in #{p.name} -> #{m.name} is mismapped"
        rt = mrt.relationship_type
        good_rt = p.relationship_types.first(:conditions => 
                                             {"doc_templates.name" =>  
                                                rt.left_template.name,
                                              :left_description => rt.left_description,
                                              :right_description => rt.right_description},
                                             :joins => [:left_template])
        if good_rt
          puts "Will remap using relationship type #{good_rt.id}"
          mrt.relationship_type = good_rt
          mrt.save!
        else
          puts "!!! Cannot find template to remap with!"
        end
      end        
    end
  end
end
