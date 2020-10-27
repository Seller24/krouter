# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name         = 'krouter'
  s.version      = '0.0.1'
  s.summary      = 'Kafka Router'
  s.description  = 'Kafka Router — bridge between core app and microservices'
  s.authors      = ['Aslan Dukaev']
  s.email        = 'dukaev999@gmail.com'
  s.homepage     = 'https://github.com/Seller24/krouter'
  s.license      = 'MIT'

  s.files        = Dir['lib/**/*']
  s.require_path = 'lib'

  s.add_dependency 'dry-inflector', '~> 0.2.0'
  s.add_dependency 'ruby-kafka', '~> 1.0.0'
  s.add_dependency 'redis', '~> 4.2.2'

  s.add_development_dependency 'bundler', '>= 2.0'
  s.add_development_dependency 'dry-monads', '~> 1.3.5'
  s.add_development_dependency 'pry', '~> 0.13.1'
  s.add_development_dependency 'rspec', '>= 2.0'
end
