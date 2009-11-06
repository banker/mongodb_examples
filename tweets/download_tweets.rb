require 'rubygems'
require 'twitter'
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

(1..5).each do |page|
  Twitter::Search.new('nyc').page(page).each do |tweet|
    @nyc.save(tweet)
  end
end

@nyc.find.each do |tweet|
  filename = tweet['from_user'].downcase + ".jpg"
  next if GridStore.exist?(@db, filename) 

  GridStore.open @db, filename, 'w+' do |file|
    data = open(tweet['profile_image_url']).read
    file.content_type = 'image/jpeg'
    file.puts data
  end
end
