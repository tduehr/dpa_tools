class WaveformProcessor
  attr_accessor :trace, :chan1_data, :chan2_data
  def initialize trace, chan1_data: nil, chan2_data: nil
    @trace = trace
    @chan1_data = chan1_data || @trace.chan1_data[10..-1]
    @chan2_data = chan2_data || @trace.chan2_data[10..-1]
  end

  def process_waveform
    fact1 = @trace.chan1_scale/25.0
    fact2 = @trace.chan2_scale/25.0
    sub1 = 240 * fact1 - (@trace.chan1_offset + @trace.chan1_scale * 4.6)
    sub2 = 240 * fact2 - (@trace.chan2_offset + @trace.chan2_scale * 4.6)
    inter = sub1 - sub2
    time_offset = @trace.time_offset
    sampling_rate = @trace.sampling_rate
    Trace.transaction do
      (chan1_data.bytesize).times do |idx|
        @trace.sample_points.create(
          # [
          #   (240 - <Raw_Byte>) * (<Volts_Div> / 25) - [(<Vert_Offset> + <Volts_Div> * 4.6)]
          # ]
          reading: inter - (chan1_data[idx].ord * fact1) + (chan2_data[idx].ord * fact2),
          timestamp: time_offset + idx / sampling_rate
        )
      end
    end
    @trace
  end
end
