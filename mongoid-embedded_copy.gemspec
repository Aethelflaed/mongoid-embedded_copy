# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'mongoid/embedded_copy/version'

Gem::Specification.new do |s|
  s.license     = 'MIT'
  s.name        = 'mongoid-embedded_copy'
  s.version     = Mongoid::EmbeddedCopy::VERSION
  s.authors     = ['Geoffroy Planquart']
  s.email       = ['geoffroy@planquart.fr']
  s.homepage    = 'https://github.com/Aethelflaed/mongoid-embedded_copy'
  s.summary     = 'Mimic a given root document to use as embedded copy'
  s.description = 'Create a mimic of a root document to use as a copy embedded in another document'

  s.files       = Dir['{lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files  = Dir['test/**/*']

  s.add_dependency 'mongoid',       '~> 4.0'
  s.add_dependency 'activesupport', '~> 4.0'
end

