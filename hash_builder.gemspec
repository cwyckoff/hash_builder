spec = Gem::Specification.new do |s|
  s.name = 'hash_builder'
  s.version = '0.0.3'
  s.date = '2009-07-09'
  s.summary = 'Hash Builder is a simple tool for offloading the building of hashes.'
  s.email = "github@cwyckoff.com"
  s.homepage = "http://github.com/cwyckoff/hash_builder"
  s.description = 'Hash Builder is a simple tool for offloading the building of hashes.'
  s.has_rdoc = true
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc", "--title", "HashBuilder - A Hash Building Tool for the Ages"]
  s.extra_rdoc_files = ["README.rdoc", "MIT-LICENSE"]
  s.authors = ["Chris Wyckoff"]
  
  s.files = ["init.rb", 
             "lib/hash_builder.rb",
             "lib/hash_builder/hash_builder.rb"]
end
