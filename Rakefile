
APPLICATION_NAME = "temp_make_text_search_tests"

task :default => "test:pg"

namespace :test do

  def run_tests(adapter)
    Process.waitpid(fork do
      Dir.chdir "/tmp"
      system "rm", "-fr", APPLICATION_NAME if File.directory?(APPLICATION_NAME)
      system "rails", "new", APPLICATION_NAME, "-d", adapter, "-G", "-J"
      Dir.chdir APPLICATION_NAME

      if db_user = ENV["DB_USER"]
        require 'yaml'
        database = YAML.load(File.read("config/database.yml"))
        database.values.each do |connection|
          connection["username"] = ENV["DB_USER"]
        end
        File.open("config/database.yml", "w") {|f| f.write database.to_yaml }
      end

      File.open("Gemfile", "a") {|f| f.puts %[\ngem "make-text-search", :path => #{File.dirname(__FILE__).inspect}] }
      system "bundle", "install"
      Dir["#{File.dirname(__FILE__)}/test/*"].each do |filename|
        File.open("test/unit/#{File.basename filename}", "w") {|f| f.write File.read(filename) }
      end

      ENV["RAILS_ENV"] = "test"
      system "rails", "g", "text_search:migration"
      exec "rake", "db:create", "db:migrate", "test", "db:drop"
    end)
  end

  desc "Run tests againts PostgreSQL"
  task :pg do
    run_tests "postgresql"
  end

  #desc "Run tests againts SQLite3"
  #task :sqlite3 do
  #  run_tests "sqlite3"
  #end

  #desc "Run tests againts MySQL"
  #task :mysql do
  #  run_tests "mysql"
  #end

end
