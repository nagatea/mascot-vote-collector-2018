require 'mysql2'
require 'dotenv'
require 'mechanize'

Dotenv.load

db = Mysql2::Client.new(
  host: ENV['DB_HOST'] || 'localhost',
  port: ENV['DB_PORT'] || 3306,
  username: ENV['DB_USER'] || 'root',
  password: ENV['DB_PASSWORD'],
  database: ENV['DB_NAME'] || 'mascot'
)

agent = Mechanize.new
agent.max_history = 1
agent.open_timeout = 60
agent.read_timeout = 180

base_url = 'https://contest.gakumado.mynavi.jp/mascot2018/photos/detail/'

date = Time.now.strftime("%Y-%m-%d")
db.prepare('INSERT INTO dates (date) VALUES (?)').execute(date)
date_id = db.last_id

(1..60).each do |id|
  page = agent.get(base_url + id.to_s)
  xpath = '//*[@id="contents"]/div/div[1]'
  content = page.search(xpath).to_s
  text = content.scan(/<p>(.+)</)
  if text[0]
    vote = text[1][0].to_i
  else
    vote = 0
  end
  puts "date_id = #{date_id}, user_id = #{id}, vote = #{vote}"
  db.prepare('INSERT INTO votes (date_id, user_id, vote) VALUES (?, ?, ?)').execute(date_id, id, vote)
  sleep(1)
end
