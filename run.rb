require 'rss'
require 'open-uri'
require 'net/http'
require 'json'

FEED_URL = "https://fischr.org/feed.xml"
API_KEY = "8935437156408e3dc185dbe8c617ba90"
KEY_LOCATION = "https://fischr.org/8935437156408e3dc185dbe8c617ba90.txt"
HOST = "fischr.org"
SUBMITTED_FILE = "submitted.txt"

def submitted_urls
  File.exist?(SUBMITTED_FILE) ? File.read(SUBMITTED_FILE).split("\n") : []
end

def save_submitted(urls)
  File.open(SUBMITTED_FILE, 'a') { |f| f.puts(urls) }
end

def fetch_new_urls
  urls = []
  URI.open(FEED_URL) do |rss|
    feed = RSS::Parser.parse(rss, false)
    feed.items.each do |item|
      urls << item.link
    end
  end
  urls - submitted_urls
end

def submit_to_indexnow(urls)
  return if urls.empty?

  uri = URI("https://api.indexnow.org/indexnow")
  payload = {
    host: HOST,
    key: API_KEY,
    keyLocation: KEY_LOCATION,
    urlList: urls
  }

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  req.body = payload.to_json

  response = http.request(req)
  puts "Submitted #{urls.size} URLs: #{response.code}"
end

new_urls = fetch_new_urls
submit_to_indexnow(new_urls)
save_submitted(new_urls)