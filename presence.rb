require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json/ext' # required for .to_json
require 'json'
require 'pry'

require 'dotenv'
Dotenv.load

configure do
  db = Mongo::Client.new( ENV['MONGO_URI'])
  set :mongo_db, db[:pings]
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def object_id val
    begin
      BSON::ObjectId.from_string(val)
    rescue BSON::ObjectId::Invalid
      nil
    end
  end

  def document_by_id id
    id = object_id(id) if String === id
    if id.nil?
      {}.to_json
    else
      document = settings.mongo_db.find(:_id => id).to_a.first
      (document || {}).to_json
    end
  end
end

get '/' do
  "Set your Cloudtrax Presence Reporting Server Location to: <br/>#{request.base_url}/ping"
end

get '/collections/?' do
  content_type :json
  settings.mongo_db.database.collection_names.to_json
end

# list all documents in the test collection
get '/pings/?' do
  content_type :json
  settings.mongo_db.find.to_a.to_json
end

# find a document by its ID
get '/pings/:id/?' do
  content_type :json
  document_by_id(params[:id])
end

# insert a new document from the request parameters,
# then return the full document
post '/ping/?' do
  params = JSON.parse request.body.read
  params[:timestamp] = Time.now.to_i
  content_type :json
  db = settings.mongo_db
  result = db.insert_one params
  db.find(:_id => result.inserted_id).to_a.first.to_json
end
