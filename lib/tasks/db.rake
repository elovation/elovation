namespace :db do
  task do: ["db:drop", "db:create", "db:migrate", "db:seed", "db:test:prepare"]

  task populate_data: :environment do
    require Rails.root.join("db", "seed.rb")
  end
end
