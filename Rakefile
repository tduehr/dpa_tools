require 'rubygems'
require 'rake'
require 'rake/clean'
require 'active_record'
require 'active_record/tasks/database_tasks'
require 'yaml'
require 'active_record_migrations'
ActiveRecordMigrations.load_tasks

require_relative 'lib/models'

desc "Start IRB with all runtime dependencies loaded"
task :console, [:script] do |t,args|
  # TODO move to a command
  dirs = ['ext', 'lib'].select { |dir| File.directory?(dir) }

  original_load_path = $LOAD_PATH

  cmd = if File.exist?('Gemfile')
          require 'bundler'
          Bundler.setup(:default)
        end

  # add the project code directories
  $LOAD_PATH.unshift(*dirs)

  # clear ARGV so IRB is not confused
  ARGV.clear

  require 'irb'

  # set the optional script to run
  IRB.conf[:SCRIPT] = args.script
  IRB.start

  # return the $LOAD_PATH to it's original state
  $LOAD_PATH.reject! { |path| !(original_load_path.include?(path)) }
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
  YARD::Rake::YardocTask.new(:todo) do |yard|
    yard.options.concat ['--query', '@todo']
    yard.options << "--list"
  end
rescue LoadError
end
