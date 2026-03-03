require 'xcodeproj'

project_path = '/Users/jeffrey/Desktop/TranslateHelper/TranslateHelper.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Update App Target
app_target = project.targets.find { |t| t.name == 'TranslateHelper' }
app_target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'TranslateHelper/TranslateHelper.entitlements'
end

# Update Keyboard Target
keyboard_target = project.targets.find { |t| t.name == 'TranslateHelperKeyboard' }
keyboard_target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'TranslateHelperKeyboard/TranslateHelperKeyboard.entitlements'
end

project.save
puts "Entitlements added to targets successfully."
