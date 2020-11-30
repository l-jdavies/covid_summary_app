require "sinatra"
require "sinatra/reloader"

require_relative 'database_connection'
require_relative 'download_csv_files'

before do
  @db = CovidDatabase.new
  @csv = ObtainCsv.new
end

after do 
  @db.disconnect
end

get "/" do
  erb :welcome
end
