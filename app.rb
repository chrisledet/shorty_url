# Chris Ledet
# URL Shorty
# app.rb

require 'sinatra'
require 'sequel'
require 'haml'
require 'less'

helpers do 
  def link_to(title, url)
    "<a href='#{url}'>#{title}</a>"
  end

  def fix_url url
    url.scan(/http/).empty? ? "http://#{url}" : url
  end

end

# database name for our app
DB_NAME = :short_urls
# used to convert the integer to a short string
BASE = 36

# configuring our sqlite database
configure do
  DB = Sequel.sqlite
  DB.create_table DB_NAME do
    primary_key :id
    string :url
  end
end

# doing it with style
get '/stylesheet.css' do
  less :stylesheet
end

# index
get '/' do
  p "in index"
  haml :index
end

# post, output shorty url
post '/' do
  url = params[:url]
  items = DB[DB_NAME]
  id = items.insert(:url => url)
  @url = request.url + id.to_s(BASE)
  haml :success
end

# find the url, retrieve it, and redirct user
get '/:shorty' do
  items = DB[DB_NAME]
  shorty = params[:shorty]
  shorty_id = shorty.to_i BASE
  item = items.first(:id => shorty_id)
  url = fix_url item[:url]
  redirect url
end
