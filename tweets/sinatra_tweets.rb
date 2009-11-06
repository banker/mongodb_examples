require 'rubygems'
require 'sinatra'
require 'mongo'
require 'mongo/gridfs'
require 'download_tweets'
include GridFS
DB  = Mongo::Connection.new.db(DATABASE_NAME)

get '/' do 
  @nyc     = DB.collection('nyc')
  @tweets  = @nyc.find
  @count   = @tweets.count
  erb :tweets
end

get '/regex' do 
  @nyc     = DB.collection('nyc')
  regex    = Regexp.new(params['regex'], true)
  @tweets  = @nyc.find(:text => regex)
  @count   = @tweets.count
  erb :tweets
end

get '/time' do 
  @nyc     = DB.collection('nyc')
  @tweets = @nyc.find(:created_at => {"$lte" => params['time']})
  @count   = @tweets.count
  erb :tweets
end

get '/images/:id' do 
  content_type "image/jpeg"
  filename = params[:id].downcase + ".jpg"
  GridStore.read(DB, filename)
end
