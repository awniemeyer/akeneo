# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'akeneo'
  spec.version       = '1.6.1'
  spec.authors       = ['AWN Dev Team']
  spec.email         = ['edv@awn.de']

  spec.summary       = 'API client for accessing Akeneo'
  spec.description   = 'API client for accessing Akeneo'
  spec.homepage      = 'https://github.com/awniemeyer/akeneo'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = spec.homepage
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'webmock'
  spec.add_dependency 'httparty', '~> 0.17.0'
  spec.add_dependency 'mime-types'
  spec.add_dependency 'redis'
  spec.add_dependency 'semantic_logger'
end
