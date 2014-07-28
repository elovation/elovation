namespace :db do
  task do: ["db:drop", "db:create", "db:migrate", "db:populate_data", "db:test:prepare"]

  task populate_data: :environment do
    require Rails.root.join("db", "populate_data.rb")
  end
end
