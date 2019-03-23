languages_yml = File.read('config/languages.yml')
languages = YAML.load(languages_yml)
languages.each do |language|
  Tag.create(name: language.flatten[0].to_s)
end

StaticAnalysis.create(
  title: 'Rails Best Practices',
  search_name: :rails_best_practices
)