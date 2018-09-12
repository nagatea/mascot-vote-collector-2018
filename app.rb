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


  get 'api/votes' do
    query = 'SELECT votes.id, dates.date, users.id, users.name, users.owner_name, votes.vote FROM votes INNER JOIN users ON votes.user_id = users.id INNER JOIN dates ON votes.date_id = dates.id'
    data = []
    db.prepare(query).execute.each do |user|
      next if user['name'] == 'undefined'
      data.push user
    end
    json data
  end

  get '/api/votes/:date' do
    unless params[:date].nil?
      begin
        date = Date.parse(params[:date])
      rescue
        return 400
      end
    end

    data = []
    query = 'SELECT dates.id as date_id, dates.date, users.id, users.name, users.owner_name, votes.vote FROM votes INNER JOIN users ON votes.user_id = users.id INNER JOIN dates ON votes.date_id = dates.id WHERE dates.date = ?'
    data = db.prepare(query).execute(date.to_s).to_a
    
    yesterday_date_id = data.first['date_id'] - 1
    query = 'SELECT * from votes WHERE votes.date_id = ?'
    yes_data = []
    yes_data = db.prepare(query).execute(yesterday_date_id).to_a
    yes_data.each do |user|
      user_id = user['user_id']
      data[user_id - 1][:difference] = data[user_id - 1]['vote'] - user['vote']
    end

    yes_data.sort_by! do |user|
      user['vote']
    end
    yes_data.reverse!
    i = 1
    yes_data.each do |user|
      user[:rank] = i
      i += 1
    end
    yes_data.sort_by! do |user|
      user['id']
    end

    data.sort_by! do |user|
      user['vote']
    end
    data.reverse!
    i = 1
    data.each do |user|
      user[:rank] = i
      i += 1
    end
    data.sort_by! do |user|
      user['id']
    end

    data.each do |user|
      user_id = user['id']
      user[:rank_difference] = yes_data[user_id - 1][:rank] - user[:rank]
    end

    data.sort_by! do |user|
      user['vote']
    end
    data.reverse!

    data.delete_if {|user| user['name'] == 'undefined' }

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

  get '/api/datasets/:id' do
    data = {}
    id = params[:id]

    labels = []  
    db.prepare('SELECT date from dates').execute.each do |date|
      labels.push date['date']
    end
    data[:labels] = labels
    random = Random.new
    datasets = []
    db.prepare('SELECT id, name, owner_name FROM users WHERE id = ?').execute(id).each do |user|
      tmp = {}
      tmp[:label] = user['name']
      tmp[:owner_name] = user['owner_name']
      vote_data = []
      db.prepare('SELECT vote FROM votes WHERE user_id = ?').execute(id).each do |row|
        vote_data.push(row['vote'])
      end
      tmp[:data] = vote_data
      tmp[:borderColor] = "rgb(#{random.rand(255)},#{random.rand(255)},#{random.rand(255)})"
      tmp[:lineTension] = 0
      tmp[:fill] = false
      datasets.push(tmp)
    end
    data[:datasets] = datasets
    json data
  end
end