languages_yml = File.read('config/languages.yml')
languages = YAML.load(languages_yml)
languages.each do |language|
  Tag.create(name: language.flatten[0].to_s)
end
