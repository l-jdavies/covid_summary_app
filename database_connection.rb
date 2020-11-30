require 'pg'
require 'byebug'

class CovidDatabase
  def initialize
    @db = PG.connect(dbname: 'covid') 
  end

  def setup_tables_data
    create_all_tables
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
    sql = ("SELECT * FROM hi_current_data WHERE id = 1")
    result = @db.exec(sql)
    column_headers = tuple_to_hash(result)
 
    expected_values = ["1", "positive", "hospitalizedCumulative", "death", "totalTestResults"]

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
    copy_from_csv('./csv/hi_current.csv', 'hi_current_data')
    copy_from_csv('./csv/hi_seven_day.csv', 'hi_seven_day_data')
    copy_from_csv('./csv/hi_fourteen_day.csv', 'hi_fourteen_day_data')

    copy_from_csv('./csv/ak_current.csv', 'ak_current_data')
    copy_from_csv('./csv/ak_seven_day.csv', 'ak_seven_day_data')
    copy_from_csv('./csv/ak_fourteen_day.csv', 'ak_fourteen_day_data')

    copy_from_csv('./csv/gu_current.csv', 'gu_current_data')
    copy_from_csv('./csv/gu_seven_day.csv', 'gu_seven_day_data')
    copy_from_csv('./csv/gu_fourteen_day.csv', 'gu_fourteen_day_data')
  end


# csv file contains more columns than I want to import into postgresql
  # I'll create a tmp table in sql into which all data from the csv file will be copied
  # Then I'll copy the required columns from the temp table into my final tables
  def copy_from_csv(csv_file, dest_table)
    create_table('temp_schema.sql')
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
        SELECT col3, col10, col20, col8 FROM tmp
        ;
        SQL
  end

  def create_all_tables
   create_table('hi_schema.sql')
   create_table('ak_schema.sql')
   create_table('gu_schema.sql')
  end

  def create_table(schema)
    sql = File.open(schema, 'rb') { |file| file.read }
    begin
      @db.exec(sql)
    rescue PG::Error
      puts "Problem creating table"
    end
  end

end
