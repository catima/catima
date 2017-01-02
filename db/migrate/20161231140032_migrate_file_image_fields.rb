class MigrateFileImageFields < ActiveRecord::Migration
  def up
    Rake::Task['data:migrate_file_fields'].invoke
  end
end
