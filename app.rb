require 'sinatra/base'
require "sinatra/json"
require 'mysql2'
require 'dotenv'
require 'date'

Dotenv.load

class App < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/client/dist'

  helpers do
    def config
      @config ||= {
        db: {
          host: ENV['DB_HOST'] || 'localhost',
          port: ENV['DB_PORT'] || 3306,
          username: ENV['DB_USER'] || 'root',
          password: ENV['DB_PASSWORD'],
          database: ENV['DB_NAME'] || 'mascot',
        }
      }
    end

    def db
      return Thread.current[:mascot_db] if Thread.current[:mascot_db]
      client = Mysql2::Client.new(
        host: config[:db][:host],
        port: config[:db][:port],
        username: config[:db][:username],
        password: config[:db][:password],
        database: config[:db][:database],
        reconnect: true,
      )
      Thread.current[:mascot_db] = client
      client
    end
  end

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  get '/api/users' do
    data = db.prepare('SELECT * FROM users').execute.to_a
    json data
  end

  get '/api/users/:id' do
    id = params[:id].to_s
    data = db.prepare('SELECT * FROM users WHERE id = ?').execute(id).first
    json data
  end

  get '/api/dates' do
    data = db.prepare('SELECT * FROM dates').execute.to_a
    json data
  end

  get '/api/votes' do
    query = 'SELECT votes.id, dates.date, users.name, users.owner_name, votes.vote FROM votes INNER JOIN users ON votes.user_id = users.id INNER JOIN dates ON votes.date_id = dates.id'
    unless params[:date].nil?
      begin
        date = Date.parse(params[:date]).to_s
      rescue
        return 400
      end
      query << " WHERE dates.date = '#{date}'"
    end
    data = db.prepare(query).execute.to_a
    json data
  end

  get '/api/datasets' do
    data = {}

    labels = []  
    db.prepare('SELECT date from dates').execute.each do |date|
      labels.push date['date']
    end
    data[:labels] = labels
    random = Random.new
    datasets = []
    db.prepare('SELECT id, name FROM users').execute.each do |user|
      next if user['name'] == 'undefined'
      tmp = {}
      tmp[:label] = user['name']
      vote_data = []
      db.prepare('SELECT vote FROM votes WHERE user_id = ?').execute(user['id']).each do |row|
        vote_data.push(row['vote'])
      end
      tmp[:data] = vote_data
      tmp[:borderColor] = "rgb(#{random.rand(255)},#{random.rand(255)},#{random.rand(255)})"
      tmp[:lineTension] = 0
      tmp[:fill] = false
      datasets.push(tmp)
    end
    data[:datasets] = datasets.sort_by { |user| user[:data].last}.reverse
    json data
  end
end