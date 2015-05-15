source 'https://rubygems.org'

gem 'chef', '~> 12.0'

group :lint do
  gem 'foodcritic'
  gem 'rubocop', '>= 0.24'
end

group :unit do
  gem 'berkshelf', '>= 3.1'
  gem 'chefspec', '>= 4.2.0'
  gem 'ci_reporter_rspec'
end

group :development do
  gem 'rake'
end

group :knife do
  gem 'knife-cookbook-doc'
  gem 'knife-supermarket'
  gem 'knife-spork'
end

# Kitchen
group :kitchen do
  gem 'test-kitchen', '~> 1.3'
  gem 'kitchen-docker'
  gem 'kitchen-vagrant'
end
