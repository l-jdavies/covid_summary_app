require 'date'
require 'open-uri'
require 'csv'

class ObtainCsv
  attr_reader :current_date, :seven_day_date, :fourteen_day_date
  
  def initialize(selected_state)
    @current_date = create_current_date
    @seven_day_date = create_date_seven_days_previous
    @fourteen_day_date = create_date_fourteen_days_previous
    @state = selected_state
  end

  def download_state_csv_files
    state_current_api = "https://api.covidtracking.com/v1/states/#{@state}/#{@current_date}.csv"
    download_csv(state_current_api, "state_current")
    

    state_seven_day_api = "https://api.covidtracking.com/v1/states/#{@state}/#{@seven_day_date}.csv"
    download_csv(state_seven_day_api, "state_seven_day")

    state_fourteen_day_api = "https://api.covidtracking.com/v1/states/#{@state}/#{@fourteen_day_date}.csv"
    download_csv(state_fourteen_day_api, "state_fourteen_day")
  end

  private

  def create_current_date
    Date.today.prev_day(1).to_s.delete('-')
  end

  def create_date_seven_days_previous
    Date.today.prev_day(8).to_s.delete('-')
  end

  def create_date_fourteen_days_previous
    Date.today.prev_day(15).to_s.delete('-')
  end

  def download_csv(api_address, file_name)
    api = URI(api_address)

    URI.open(api) do |data|
      File.open("#{file_name}.csv", "wb") do |file|
        file.write(data.read)
      end
        end
  end
end
