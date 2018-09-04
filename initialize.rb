require 'mysql2'
require 'dotenv'
require 'mechanize'

Dotenv.load

db = Mysql2::Client.new(
    host: ENV['DB_HOST'] || 'localhost',
    port: ENV['DB_PORT'] || 3306,
    username: ENV['DB_USER'] || 'root',
    password: ENV['DB_PASSWORD'],
    database: ENV['DB_NAME'] || 'mascot',
)

agent = Mechanize.new
agent.max_history = 1
agent.open_timeout = 60
agent.read_timeout = 180

db.prepare('DELETE FROM users WHERE id >= 1').execute

base_url = 'https://contest.gakumado.mynavi.jp/mascot2018/photos/detail/'

(54..60).each do |id|
  page = agent.get(base_url + id.to_s)
  xpath = '//*[@id="contents"]/div/div[1]'
  content = page.search(xpath).to_s
  text = content.scan(/<p>(.+)</)
  if text[0]
    name = text[3][0]
    owner_name = text[4][0]
  else
    name = "undefined"
    owner_name = "undefined"
  end
  puts "id = #{id}, name = #{name}, owner_name = #{owner_name}"
  db.prepare('INSERT INTO users (id, name, owner_name) VALUES (?, ?, ?)').execute(id, name, owner_name)
  sleep(1)
end
