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

get "/state" do
  @state = params[:state_name].upcase

  redirect "/results?state_name=#{@state}"
end

get "/" do
  
  erb :welcome
end

get "/results" do
  params[:test] = params['state_name']

  @state = params[:test]
  redirect "/testing"
end

get "/testing" do
  byebug
end


