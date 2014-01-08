require 'serialport'

class EvalBoard < SerialPort
  attr_accessor :keygen
  def initialize *args, &block
    super *args
    if block_given?
      @keygen = block
    else
      @keygen = ->(*args){ query 'r' }
    end
  end

  def randomize_key! *args
    self.key = @keygen.call *args
  end

  def randomize_plaintext!
    query "R"
  end

  def query req
    self.write req
    self.readline.strip
  end

  def key
    query 'K'
  end

  def key= k
    query "k#{k}"
  end

  def plaintext
    query 'P'
  end

  def plaintext= plain
    query "p#{plain}"
  end

  def encrypt
    query 'E'
  end

  def decrypt
    query 'e'
  end

  def debug
    !query('D').empty?
  end

  def debug= flag
    query "d#{flag ? 1 : 0}"
  end
end
