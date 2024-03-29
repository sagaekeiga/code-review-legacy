# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
languages_yml = File.read('config/languages.yml')
languages = YAML.load(languages_yml)
languages.each do |language|
  Tag.create(name: language.flatten[0].to_s)
end

FactoryBot.create_list(:user, 10, :with_user_tags)

Admin.create(email: 'admin@example.com', password: 'hogehoge')