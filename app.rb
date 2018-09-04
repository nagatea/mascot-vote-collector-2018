require 'sinatra/base'
require "sinatra/json"
require 'mysql2'
require 'dotenv'

Dotenv.load

class App < Sinatra::Base
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
    'Hello world!'
  end

  get '/api/users' do
    data = Array.new
    db.prepare('SELECT * FROM users').execute.each { |row| data << row }
    puts data.inspect
    json data
  end
end