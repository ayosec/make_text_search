
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
generate "model", "User", "name:string", "description:text", "type:string"

File.open("app/models/post.rb", "a") do |f|
  f.puts "\nPost.has_text_search :title, :filter => :substrings"
  f.puts "Post.has_text_search :content, :filter => [:substrings, :strip_html]"
end

File.open("app/models/user.rb", "a") do |f|
  f.puts "\nUser.has_text_search :name, :description"
end

File.open("app/models/admin.rb", "w") do |f|
  f.puts "class Admin < User\nend"
end

# Copy tests from the gem
Dir["#{ENV["MTS_GEM_PATH"]}/test/*_test.rb"].each do |filename|
  file "test/unit/#{File.basename filename}", File.read(filename)
end

File.unlink "test/fixtures/posts.yml"
File.unlink "test/fixtures/users.yml"
