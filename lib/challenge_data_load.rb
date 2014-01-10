#!/usr/bin/env ruby

require 'yaml'
require 'csv'
require_relative 'models'

# ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(YAML.load_file('db/config.yml')['development'])

path = ARGV.first
raise 'must supply path' unless path && File.exists?(path) && File.directory?(path)

$queue = Queue.new

Dir[File.join path, '*.csv'].each do |file|
  $queue.push file
end

2.times.map do
  $queue.push nil
  Thread.new do
    while(file = $queue.pop)
      ActiveRecord::Base.connection_pool.with_connection do
        warn file
        _, impl, key, msg, ctxt = File.basename(file,'.*').match(/(\w*_([[:alpha:]]+)_\w*[[:alpha:]]).*k=([[:xdigit:]]+)_m=([[:xdigit:]]+)_c=([[:xdigit:]]+)/).to_a
        impl = Implementation.where(name: impl).first_or_create(algorithm: impl.split('_')[1])

        trace = Trace.where(trace_type: :current, plain_text: msg, cipher_text: ctxt, key: key).first_or_create do |trace|
          Trace.transaction do
            CSV.foreach(file, converters: :numeric) do |row|
              SamplePoint.create( timestamp: row[0], reading: row[1], trace_id: trace.id)
            end
          end
        end
        Trace.reset_counters trace.id, :sample_points
      end
    end
  end
end.map &:join
