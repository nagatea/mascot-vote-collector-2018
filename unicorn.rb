require "dotenv"
Dotenv.load

@path = ENV["DIRECTORY_PATH"]

worker_processes 1 
working_directory @path
listen '/tmp/unicorn.sock' 
pid "#{@path}/tmp/pids/unicorn.pid" 

stderr_path "#{@path}/log/unicorn.stderr.log"
stdout_path "#{@path}/log/unicorn.stdout.log"
preload_app true