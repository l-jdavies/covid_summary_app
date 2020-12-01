require 'pg'

class CovidDatabase
  def initialize
    @db = PG.connect(dbname: 'covid') 
  end

  def setup_tables_data
    create_state_table
    copy_all_files_from_csv
    validate_column_contents
  end

  def calculate_change_case_numbers(db1, db2)
    result = @db.exec <<~SQL
    SELECT CAST(#{db1}.positive_cases as INTEGER) - CAST(#{db2}.positive_cases as INTEGER) AS positive_cases,
      CAST(#{db1}.hospitalizations as INTEGER) - CAST(#{db2}.hospitalizations as INTEGER) AS hospitalizations,
      CAST(#{db1}.deaths as INTEGER) - CAST(#{db2}.deaths as INTEGER) AS deaths,
      CAST(#{db1}.total_test_results as INTEGER) - CAST(#{db2}.total_test_results as INTEGER) AS total_test_results
      FROM #{db1} JOIN #{db2} 
      ON (#{db1}.id = #{db2}.id)
    WHERE #{db1}.id = 2;
    SQL

    tuple_to_hash(result)
  end

  def disconnect
    @db.close
  end

  private

  # check the columns contains the expected data - covid tracking could change the column numbers (this should be improved)
  # I'll just validate one table - assuming that if csv files have been altered then all tables will be affected
  def validate_column_contents
    sql = ("SELECT * FROM state_current_data WHERE id = 1")
    result = @db.exec(sql)
    column_headers = tuple_to_hash(result)
 
    expected_values = ["1", "positive", "hospitalizedCurrently", "death", "totalTestResults"]

    puts ""
    column_headers.values.each_with_index do |val, idx|
      if val == expected_values[idx]
        puts "'#{val}' column is correct"
      else
        abort("ERROR!! '#{val}' DOES NOT CONTAIN CORRECT VALUE")
      end
    end
  end

  def tuple_to_hash(psql_result)
    hsh = psql_result.map do |tuple|
      { id: tuple["id"],
        positive_cases: tuple["positive_cases"],
        hospitalizations: tuple["hospitalizations"],
        deaths: tuple["deaths"],
        total_test_results: tuple["total_test_results"]}
    end
    hsh[0]
  end

  def copy_all_files_from_csv
    copy_from_csv('state_current.csv', 'state_current_data')
    copy_from_csv('state_seven_day.csv', 'state_seven_day_data')
    copy_from_csv('state_fourteen_day.csv', 'state_fourteen_day_data')
  end


# csv file contains more columns than I want to import into postgresql
  # I'll create a tmp table in sql into which all data from the csv file will be copied
  # Then I'll copy the required columns from the temp table into my final tables
  def copy_from_csv(csv_file, dest_table)
    create_tmp_table
    @db.copy_data("COPY tmp FROM STDIN CSV") do
      File.foreach(csv_file, 'r').each do |line|
        begin
          @db.put_copy_data(line)
        rescue PG::InvalidTextRepresentation
          puts "error copying into temp"
        end
      end
    end

    # copy from tmp table into final table 
    @db.exec <<~SQL
      INSERT INTO #{dest_table}
      (positive_cases, hospitalizations, deaths, total_test_results)
        SELECT col3, col9, col20, col8 FROM tmp
        ;
        SQL
  end

  def create_table(schema)
    sql = File.open(schema, 'rb') { |file| file.read }
    begin
      @db.exec(sql)
    rescue PG::Error
      puts "Problem creating table"
    end
  end

  def create_state_table
    @db.exec <<~SQL
      DROP TABLE IF EXISTS state_current_data;
      DROP TABLE IF EXISTS state_seven_day_data;
      DROP TABLE IF EXISTS state_fourteen_day_data;

      CREATE TABLE state_current_data (
        id serial PRIMARY KEY,
        positive_cases text NOT NULL,
        hospitalizations text NOT NULL,
        deaths text NOT NULL,
        total_test_results text NOT NULL
      );

      CREATE TABLE state_seven_day_data (
        id serial PRIMARY KEY,
        positive_cases text NOT NULL,
        hospitalizations text NOT NULL,
        deaths text NOT NULL,
        total_test_results text NOT NULL
      );

      CREATE TABLE state_fourteen_day_data (
        id serial PRIMARY KEY,
        positive_cases text NOT NULL,
        hospitalizations text NOT NULL,
        deaths text NOT NULL,
        total_test_results text NOT NULL
      );
      SQL
  end

  def create_tmp_table
    @db.exec <<~SQL
      DROP TABLE IF EXISTS tmp;

      CREATE TABLE tmp (
        col1 text,
        col2 text,
        col3 text,
        col4 text,
        col5 text,
        col6 text,
        col7 text,
        col8 text,
        col9 text,
        col10 text,
        col11 text,
        col12 text,
        col13 text,
        col14 text,
        col15 text,
        col16 text,
        col17 text,
        col18 text,
        col19 text,
        col20 text,
        col21 text,
        col22 text,
        col23 text,
        col24 text,
        col25 text,
        col26 text,
        col27 text,
        col28 text,
        col29 text,
        col30 text,
        col31 text,
        col32 text,
        col33 text,
        col34 text,
        col35 text,
        col36 text,
        col37 text,
        col38 text,
        col39 text,
        col40 text,
        col41 text,
        col42 text,
        col43 text,
        col44 text,
        col45 text,
        col46 text,
        col47 text,
        col48 text,
        col49 text,
        col50 text,
        col51 text,
        col52 text,
        col53 text,
        col54 text,
        col55 text
      );
      SQL
  end

end
