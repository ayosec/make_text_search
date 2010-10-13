
if db_user = ENV["DB_USER"]
  require 'yaml'
  database = YAML.load(File.read("config/database.yml"))
  database.values.each do |connection|
    connection["username"] = ENV["DB_USER"]
  end
  File.open("config/database.yml", "w") {|f| f.write database.to_yaml }
end

gem "make-text-search", :path => ENV["MTS_GEM_PATH"]

generate "text_search:migration"
generate "model", "Post", "title:string", "content:text"

File.open("app/models/post.rb", "a") {|f| f.puts "\nPost.has_text_search :title, :content" }

# Copy tests from the gem
Dir["#{ENV["MTS_GEM_PATH"]}/test/*_test.rb"].each do |filename|
  file "test/unit/#{File.basename filename}", File.read(filename)
end

