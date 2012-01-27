namespace :db do
  task :do => ["db:drop", "db:create", "db:migrate", "db:test:prepare"]
end
