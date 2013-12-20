class TraceProcessor
  def initialize key='dpa'
    @key = key
    @block = block
  end

  def process_waveform *args
    args.each do |wav|
      
      fact1 = (wav[:chan1_scale]/25.0 - (wav[:chan1_offset] + wav[:chan1_scale] * 4.6))/wav[:resistor]
      fact2 = (wav[:chan2_scale]/25.0 - (wav[:chan2_offset] + wav[:chan2_scale] * 4.6))/wav[:resistor]
      tfact = wav[:time_offset] - (wav[:chan2_data].bytesize - 10)
      waveform = wav[:chan1_data][10..-1].bytes.each_with_object({amplitude: [], time: []}) do |pnt, wave|
        (240 - pnt)*fact1 - (240 - wav[:chan2_data][wave[amp:].size + 10].ord)*fact2
      end

      
    end
  end
end