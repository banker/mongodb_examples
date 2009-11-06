require 'rubygems'
require 'rubytter'
require 'open-uri'

require 'mongo'
require 'mongo/gridfs'
include Mongo
include GridFS

DATABASE_NAME = "frank"

# DB connection and collection
@db      = Mongo::Connection.new.db(DATABASE_NAME)
@nyc     = @db.collection('nyc')

# Clear the collection
@nyc.remove

# Twitter client
@twitter = Rubytter.new

(1..5).each do |page|
  @twitter.search('nyc', :page => page).each do |tweet_hash|
    @nyc.save(tweet_hash)
  end
end

@nyc.find.each do |cursor|
  filename = cursor['user']['id']
  next if GridStore.exist?(@db, filename) 

  GridStore.open @db, filename, 'w+' do |file|
    data = open(cursor['user']['profile_image_url']).read
    file.content_type = 'image/jpeg'
    file.puts data
  end
end
