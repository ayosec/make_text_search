
APPLICATION_NAME = "temp_make_text_search_tests"

task :default => "test:pg"

namespace :test do

  def run_tests(adapter)
    Process.waitpid(fork do
      ENV["MTS_GEM_PATH"] = File.dirname(__FILE__)

      Dir.chdir "/tmp"
      system "rm", "-fr", APPLICATION_NAME if File.directory?(APPLICATION_NAME)
      system "rails", "new", APPLICATION_NAME, "-d", adapter, "-G", "-J", "-m", "#{ENV["MTS_GEM_PATH"]}/test/app_template.rb"

      Dir.chdir "/tmp/#{APPLICATION_NAME}"
      exec "rake", "RAILS_ENV=test", "db:create", "db:migrate", "test", "db:drop"
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
