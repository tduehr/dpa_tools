require 'ds1102d'
require 'securerandom'
require_relative 'eval_board'

class Fetcher
  attr_reader :scope, :board
  attr_accessor :implementation
  def initialize resistor: 10, implementation: nil, resource: nil, dev: nil, baud: 9600, data_bits: 8, parity: 0, stop_bits: 1, keygen: nil, &block
    dev ||= Dir.glob('/dev/tty.uart*').first
    @scope = Ds1102d.new resource
    @implementation = implementation
    @resistor = resistor
    @connect_opts = {resource: resource, dev: dev, baud: baud, data_bits: data_bits, parity: parity, stop_bits: stop_bits, keygen: keygen}
    connect @connect_opts
    self if block_given?
  end

  def connect resource: nil, dev: nil, baud: 9600, data_bits: 8, parity: 0, stop_bits: 1, keygen: nil
    @scope.open(resource || @scope.address || @scope.session.find_resources('USB*').first) unless @scope.connected?
    unless @board && !@board.closed?
      dev ||= Dir.glob('/dev/tty.uart*').first
      @board = EvalBoard.open dev, baud, data_bits, stop_bits, parity
    end
    self
  end

  def get count = 1, &block
    arr = count.times.map do |x|
      hsh = {}
      hsh[:implementation_id] = @implementation.id if @implementation
      hsh[:plain_text] = @board.plaintext
      hsh[:cipher_text] = @board.encrypt
      hsh[:time_scale] = @scope.timebase.scale.to_f
      hsh[:time_offset] = @scope.timebase.offset.to_f
      hsh[:chan1_scale] = @scope.channel(1).scale.to_f
      hsh[:chan1_offset] = @scope.channel(1).offset.to_f
      hsh[:chan2_scale] = @scope.channel(2).scale.to_f
      hsh[:chan2_offset] = @scope.channel(2).offset.to_f
      hsh[:chan2_data] = @scope.waveform.data 'chan2'
      hsh[:chan1_data] = @scope.waveform.data 'chan1'
      hsh[:digital_data] = @scope.waveform.data 'digital'
      hsh[:digital_source] = @scope.trigger.edge.source[/\d+/].to_i
      hsh[:digital_position] = @scope.digital(hsh[:digital_source]).position
      hsh[:sampling_rate] = @scope.acquire.sampling_rate('chan2').to_f
      hsh[:resistor] = @resistor
      if block_given?
        yield hsh
      else
        hsh
      end
    end
    arr
  end

  def method_missing meth, *args, &block
    rec = [@scope, @board].detect{|x| x.respond_to? meth}
    super unless rec
    rec.send meth, *args, &block
  end
end

if $0 == __FILE__
  require 'optparse'
  require 'ostruct'
  require_relative 'models'
  $trace_logger = ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT)
  options = OpenStruct.new
  OptionParser.new do |opts|
    opts.on()
  end.parse!
end
