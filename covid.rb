require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

require_relative 'database_connection'
require_relative 'download_csv_files'

before do
  @db = CovidDatabase.new
end

after do 
  @db.disconnect
end

configure do
  enable :sessions
end

def download_csv_files(state)
  @csv = ObtainCsv.new(state)
  @csv.download_state_csv_files
end

def copy_csv_files_to_psql
  @db.setup_tables_data
end

def calculate_new_cases
  @current_seven_day_changes = @db.calculate_change_case_numbers("state_current_data", "state_seven_day_data")
  @previous_seven_day_changes = @db.calculate_change_case_numbers("state_seven_day_data", "state_fourteen_day_data")
end

def calculate_percentage_changes(current_wk, previous_wk)
  hsh = {}
  current_wk.each do |key, value|
    next if key == :id

    if current_wk[key].to_i > previous_wk[key].to_i
      change = percentage_increase(current_wk[key], previous_wk[key])
      hsh[key] = "increased by: #{change}%"
    elsif current_wk[key].to_i < previous_wk[key].to_i
      change = percentage_decrease(current_wk[key], previous_wk[key])
      hsh[key] = "decreased by: #{change}%"
    elsif current_wk[key].to_i == previous_wk[key].to_i
      hsh[key] = "not changed."
    else
      hsh[key] = "no data available."
    end
  end
  hsh
end

def percentage_increase(current_wk_val, previous_wk_val)
  percent = ((current_wk_val.to_f - previous_wk_val.to_f) / previous_wk_val.to_f) * 100
  '%.2f' % percent
end
  
def percentage_decrease(current_wk_val, previous_wk_val)
  percent = ((previous_wk_val.to_f - current_wk_val.to_f) / previous_wk_val.to_f) * 100
  '%.2f' % percent
end

def get_dates
  @current_date = @csv.current_date
  @seven_day_date = @csv.seven_day_date
  @fourteen_day_date = @csv.fourteen_day_date
end

helpers do
  def print_change_results
    ["The number of positive cases have increased by #{@current_seven_day_changes[:positive_cases]}",
     "The number of individuals currently hospitalized has increased by #{@current_seven_day_changes[:hospitalizations]}",
     "The number of deaths have increased by #{@current_seven_day_changes[:deaths]}",
     "The number of total tests performed has increased by #{@current_seven_day_changes[:total_test_results]}"]
  end

  def print_percent_change_results
    percent_changes = calculate_percentage_changes(@current_seven_day_changes, @previous_seven_day_changes)

    ["Positive cases have #{percent_changes[:positive_cases]}",
    "Individuals currently hospitalized has #{percent_changes[:hospitalizations]}",
    "Deaths have #{percent_changes[:deaths]}",
    "Total tests performed have #{percent_changes[:total_test_results]}"]
  end
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
  get_dates

  @change_results = print_change_results
  @change_percent = print_percent_change_results
  erb :results
end

