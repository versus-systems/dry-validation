source 'https://rubygems.org'

gemspec

gem 'dry-logic', github: 'dry-rb/dry-logic', branch: 'master'
gem 'dry-types', github: 'dry-rb/dry-types', branch: 'master'
gem 'dry-struct', github: 'dry-rb/dry-struct', branch: 'master'

group :test do
  gem 'i18n', require: false
  gem 'codeclimate-test-reporter', platform: :rbx
end

group :tools do
  gem 'byebug', platform: :mri
  gem 'hotch', platform: :mri
  gem 'pry', platform: :mri

  unless ENV['TRAVIS']
    gem 'mutant', github: 'mbj/mutant', platform: :mri
    gem 'mutant-rspec', github: 'mbj/mutant', platform: :mri
  end
end

group :benchmarks do
  gem 'activemodel', '~> 5.0.0.rc', platform: :mri
  gem 'actionpack', '~> 5.0.0.rc', platform: :mri
  gem 'benchmark-ips', platform: :mri
  gem 'virtus', platform: :mri
end
