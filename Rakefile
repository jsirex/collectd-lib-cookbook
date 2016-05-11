#!/usr/bin/env rake
require 'rake'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

cookbook_dir = File.expand_path File.dirname(__FILE__)
ENV['BERKSHELF_PATH'] = cookbook_dir + '/.berkshelf'
ENV['CI_REPORTS'] = cookbook_dir + '/reports'

task default: 'quick'

RSpec::Core::RakeTask.new(:spec => ['ci:setup:rspec'])

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, how do you test?' unless ENV['CI']
rescue Kitchen::UserError => e
  puts "Warn: #{e}"
end

begin
  require 'foodcritic'

  FoodCritic::Rake::LintTask.new do |t|
    t.options = {
      progress: true,
      fail_tags: %w(any)
    }
  end
rescue LoadError
  warn 'Foodcritic Is missing ZOMG'
end

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new do |task|
    task.fail_on_error = true
  end
rescue LoadError
  warn 'Rubocop gem not installed, now the code will look like crap!'
end

begin
  require 'knife_cookbook_doc/rake_task'

  KnifeCookbookDoc::RakeTask.new(:doc) do |task|
    task.options[:cookbook_dir] = './'
    task.options[:constraints] = true
    task.options[:output_file] = 'README.md'
  end
rescue LoadError
  warn 'knife-cookbook-doc gem not installed, unable to generate documentation'
end

begin
  require 'stove/rake_task'
  Stove::RakeTask.new
rescue LoadError
  warn 'Stove gem not installed, unable to release'
end

desc 'Run all of the quick tests.'
task :quick do
  Rake::Task['doc'].invoke
  Rake::Task['rubocop'].invoke
  Rake::Task['foodcritic'].invoke
  Rake::Task['spec'].invoke
end

desc 'Run _all_ the tests. Go get a coffee.'
task :complete do
  Rake::Task['quick'].invoke
  Rake::Task['kitchen:all'].invoke
end

desc 'Run CI tests'
task :ci do
  Rake::Task['complete'].invoke
end
