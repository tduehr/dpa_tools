class Fetcher
  def initialize resource: nil, dev: nil, baud: 9600, data_bits: 8, parity: 0, stop_bits: 1
    dev ||= Dir.glob('/dev/tty.uart*').first
    @scope = Ds1102d.new resource
    @scope.open @scope.session.find_resources('USB*').first unless resource
    @serial = SerialPort.open dev, baud, data_bits, stop_bits, parity
  end

  def connect
    @scope.open @scope.address || @scope.session.find_resources('USB*').first unless @scope.connected?
  end

  def get count = 1
    arr = count.times.map do |x|
      hsh = {}
      @serial.write 'RE'
      hsh[:cipher_text] = @serial.readline
      hsh[:time_scale] = @scope.timebase.scale
      hsh[:time_offset] = @scope.timebase.offset
      hsh[:chan1_scale] = @scope.channel(1).scale
      hsh[:chan1_offset] = @scope.channel(1).offset
      hsh[:chan2_scale] = @scope.channel(2).scale
      hsh[:chan2_offset] = @scope.channel(2).offset
      hsh[:chan2_data] = @scope.waveform.data 'chan2'
      hsh[:chan1_data] = @scope.waveform.data 'chan1'
      hsh[:dig_data] = @scope.waveform.data 'digital'
      hsh[:sampling_rate] = @scope.acquire.sampling_rate
    end
    count < 2 ? arr.first : arr
  end
end