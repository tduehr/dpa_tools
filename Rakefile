require 'rubygems'
require 'rake'
require 'rake/clean'
require 'active_record'
require 'active_record/tasks/database_tasks'
require 'yaml'
require 'active_record_migrations'
ActiveRecordMigrations.load_tasks
# include ActiveRecord::Tasks

# load "active_record/railties/databases.rake"

# DatabaseTasks.env = 'development'
# ActiveRecord::Base.configurations = DatabaseTasks.database_configuration =
#   YAML.load_file('db/config.yml')
# DatabaseTasks.current_config = DatabaseTasks.database_configuration['development']
# DatabaseTasks.db_dir = 'db'
# DatabaseTasks.migrations_paths = 'db/migrate'

Dir.glob('lib/[^s]*.rb').each{|x| require_relative x}

# namespace :db do
#   namespace :migrate do
#     task :create, [:name] do |t, args|
#       File.open "#{args.name}.rb", 'w' do |file|
#         file.write <<EOF
# 
# 
# EOF
#       end
#     end
#   end
# end

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
