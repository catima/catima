class AddJsonDateToNumberFunction < ActiveRecord::Migration[4.2]
  def up
    connection.execute("
      CREATE FUNCTION bigdate_to_num(json) RETURNS NUMERIC(30,0)
      AS 'SELECT (
            CASE WHEN $1->>''Y'' IS NULL THEN 0 ELSE ($1->>''Y'')::INTEGER * POWER(10, 10) END +
            CASE WHEN $1->>''M'' IS NULL THEN 0 ELSE ($1->>''M'')::INTEGER * POWER(10, 8) END +
            CASE WHEN $1->>''D'' IS NULL THEN 0 ELSE ($1->>''D'')::INTEGER * POWER(10, 6) END +
            CASE WHEN $1->>''h'' IS NULL THEN 0 ELSE ($1->>''h'')::INTEGER * POWER(10, 4) END +
            CASE WHEN $1->>''m'' IS NULL THEN 0 ELSE ($1->>''m'')::INTEGER * POWER(10, 2) END +
            CASE WHEN $1->>''s'' IS NULL THEN 0 ELSE ($1->>''s'')::INTEGER END
          )::NUMERIC;'
      LANGUAGE SQL
      IMMUTABLE
      RETURNS NULL ON NULL INPUT;
    ")
  end

  def down
    connection.execute("
      DROP FUNCTION bigdate_to_num(json);
    ")
  end
end
