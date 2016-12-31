namespace :data do
  desc "Migrate old refile file fields to the new structure"
  task :migrate_file_fields => [:environment] do |t, args|
    DataMigration.new.migrate_file_field_structure
  end
end
