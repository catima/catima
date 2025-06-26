class FixValidateGeojsonFunction < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      CREATE OR REPLACE FUNCTION public.validate_geojson(geojson text) RETURNS boolean
      LANGUAGE plpgsql
      AS $$
        BEGIN
          RETURN ST_IsValid(ST_GeomFromGeoJSON(geojson));
        EXCEPTION WHEN others THEN
          RETURN 'f';
        END;
      $$;
    SQL
  end

  def down
    execute <<~SQL
      DROP FUNCTION IF EXISTS public.validate_geojson(text);
    SQL
  end
end
