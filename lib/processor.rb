class Processor
  def initialize key='dpa', &block
    @key = key
    @block = block
  end

  def process *args
    args.each do |wav|
      fact = wav[:chan1_scale]/25.0 - (wav[:chan1_offset] + wav[:chan1_scale] * 4.6)
      amp = wav[:chan1_data][10..-1].bytes.map do |pnt|
        (240-pnt)*fact
      end
      
    end
  end
end