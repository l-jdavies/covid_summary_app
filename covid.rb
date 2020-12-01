require "sinatra"
require "sinatra/reloader"
require "byebug"

require_relative 'database_connection'
require_relative 'download_csv_files'

before do
  @db = CovidDatabase.new
end

after do 
  @db.disconnect
end

def download_csv_files(state)
  @csv = ObtainCsv.new(state).download_state_csv_files
end

def copy_csv_files_to_psql
  @db.setup_tables_data
end

def calculate_new_cases
  @current_seven_day_changes = @db.calculate_change_case_numbers("state_current_data", "state_seven_day_data")
end


def analyse(state)
  download_csv_files(@state)
  copy_csv_files_to_psql
  calculate_new_cases
end

get "/" do
  
  erb :welcome
end

get "/state" do
  @state = params[:select_state].upcase

  analyse(@state)
end

