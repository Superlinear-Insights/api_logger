lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_logger/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_logger'
  spec.version       = ApiLogger::VERSION
  spec.authors       = ['Ashish Rao']
  spec.email         = ['ashish.r@superlinearinsights.com']

  spec.summary       = 'Simple API request/response logger for Rails applications'
  spec.description   = 'Logs API requests and responses to a database table for monitoring and debugging'
  spec.homepage      = 'https://github.com/Superlinear-Insights/api_logger'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the RSpec files which we don't want to include
  spec.files = Dir.glob(%w[
                          lib/**/*.rb
                          lib/**/*.rake
                          lib/**/*.tt
                          README.md
                          LICENSE.txt
                          Gemfile
                          Rakefile
                        ])

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 5.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.57'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'webmock', '~> 3.19'
end
