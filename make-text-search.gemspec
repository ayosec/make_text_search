
Gem::Specification.new do |s|
  s.name = "make-text-search"
  s.version = "0.1"
  s.date = "2010-10-13"
  s.authors = ["Ayose Cazorla"]
  s.email = "ayosec@gmail.com"
  s.summary = "Adapts the native Full Text Search of the RDBMS"
  s.homepage = "http://github.com/setepo/make_text_search"
  s.description = "Some RDBMS (like PostgreSQL 8.3 and newer) implement full text search directly, so you don't need external tools. This Rails plugin gives that functionality in a generic way."
  s.files = %w(lib test).map {|dir| Dir["#{dir}/*", "#{dir}/**/*" ] }.flatten + ["Rakefile", "README.rdoc"]
end
