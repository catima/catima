class EnablePostgis < ActiveRecord::Migration
  def up
    execute("CREATE EXTENSION postgis")
  end

  def down
    execute("DOWN EXTENSION postgis")
  end
end
