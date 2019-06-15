namespace :app do
  namespace :dev do
    task reset: %i[db:drop db:create db:migrate db:seed app:dev:sample]
    task sample: :environment do
      FactoryBot.create_list(:user, 2)
      FactoryBot.create(:admin)
    end
  end
end
