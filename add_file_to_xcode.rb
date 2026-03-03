require 'xcodeproj'

project_path = 'TranslateHelper.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'TranslateHelper' }

# Find the group for TranslateHelper
group = project.main_group.find_subpath('TranslateHelper', false) || project.main_group

file_path = 'TranslateHelper/TTSService.swift'

# Check if file is already in the project
unless group.files.find { |f| f.path == 'TTSService.swift' || f.path == file_path }
  # Add file to group
  file_reference = group.new_file('TTSService.swift')
  # Add file to target source build phase
  target.source_build_phase.add_file_reference(file_reference)
  puts "Added TTSService.swift to target"
else
  puts "TTSService.swift already in project"
end

project.save
