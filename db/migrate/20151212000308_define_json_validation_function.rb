class DefineJsonValidationFunction < ActiveRecord::Migration
  def up
    execute(<<-SQL)
      CREATE OR REPLACE FUNCTION validate_geojson(json TEXT) RETURNS BOOLEAN AS
      $$
      BEGIN
        RETURN ST_IsValid(ST_GeomFromGeoJSON(json));
      EXCEPTION WHEN others THEN
        RETURN 'f';
      END;
      $$
      LANGUAGE plpgsql;
    SQL
  end

  def down
    execute("DROP FUNCTION IF EXISTS validate_geojson(json TEXT);")
  end
end
