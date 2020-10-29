# frozen_string_literal: true

require_relative 'lib/task_bot/version'

Gem::Specification.new do |spec|
  spec.name          = 'task_bot'
  spec.version       = TaskBot::VERSION
  spec.authors       = ['Mylan Connolly']
  spec.email         = ['mylan@mylan.io']

  spec.summary       = 'Google Cloud Task ActiveJob backend for Rails'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/mylanconnolly/task_bot'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_runtime_dependency 'activejob'
  spec.add_runtime_dependency 'google-cloud-tasks', '~> 2.1'
  spec.add_runtime_dependency 'rack'
end
