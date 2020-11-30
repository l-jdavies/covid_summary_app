require 'date'
require 'open-uri'
require 'csv'

class ObtainCsv
  attr_reader :current_date, :seven_day_date, :fourteen_day_date
  
  def initialize
    @current_date = create_current_date
    @seven_day_date = create_date_seven_days_previous
    @fourteen_day_date = create_date_fourteen_days_previous
  end

  def download_state_csv_files
    obtain_hi_data
    obtain_ak_data
    obtain_gu_data
  end

  private

  def obtain_hi_data
    hi_current_api = "https://api.covidtracking.com/v1/states/hi/#{@current_date}.csv"
   download_csv(hi_current_api, "hi_current")

    hi_seven_day_api = "https://api.covidtracking.com/v1/states/hi/#{@seven_day_date}.csv"
   download_csv(hi_seven_day_api, "hi_seven_day")

    hi_fourteen_day_api = "https://api.covidtracking.com/v1/states/hi/#{@fourteen_day_date}.csv"
   download_csv(hi_fourteen_day_api, "hi_fourteen_day")
  end

  def obtain_ak_data
    ak_current_api = "https://api.covidtracking.com/v1/states/ak/#{@current_date}.csv"
    download_csv(ak_current_api, "ak_current")

    ak_seven_day_api = "https://api.covidtracking.com/v1/states/ak/#{@seven_day_date}.csv"
    download_csv(ak_seven_day_api, "ak_seven_day")

    ak_fourteen_day_api = "https://api.covidtracking.com/v1/states/ak/#{@fourteen_day_date}.csv"
    download_csv(ak_fourteen_day_api, "ak_fourteen_day")
  end

  def obtain_gu_data
    gu_current_api = "https://api.covidtracking.com/v1/states/gu/#{@current_date}.csv"
    download_csv(gu_current_api, "gu_current")

    gu_seven_day_api = "https://api.covidtracking.com/v1/states/gu/#{@seven_day_date}.csv"
    download_csv(gu_seven_day_api, "gu_seven_day")

    gu_fourteen_day_api = "https://api.covidtracking.com/v1/states/gu/#{@fourteen_day_date}.csv"
    download_csv(gu_fourteen_day_api, "gu_fourteen_day")
  end

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
      File.open("./csv/#{file_name}.csv", "wb") do |file|
        file.write(data.read)
      end
        end

    puts "Downloading data #{file_name}.csv"
  end
end
