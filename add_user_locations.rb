require 'xcodeproj'

project_path = 'TranslateHelper.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'TranslateHelper' }

group = project.main_group.find_subpath('TranslateHelper', false) || project.main_group

file_name = 'UserLocationsStore.swift'

unless group.files.find { |f| f.path == file_name }
  file_reference = group.new_file(file_name)
  target.source_build_phase.add_file_reference(file_reference)
  puts "Added #{file_name} to TranslateHelper target"
else
  puts "#{file_name} already in project"
end

project.save
