require 'active_record'
require 'active_support/all'

class Trace < ActiveRecord::Base
  belongs_to :implementation, inverse_of: :traces, counter_cache: true
  has_many :sample_points, inverse_of: :trace
  has_many :processed_texts, inverse_of: :trace
end

class ProcessedText < ActiveRecord::Base
  belongs_to :trace, inverse_of: :processed_texts
  belongs_to :user, inverse_of: :processed_texts
end

class SamplePoint < ActiveRecord::Base
  belongs_to :trace, inverse_of: :sample_points, counter_cache: true
end

class Implementation < ActiveRecord::Base
  has_many :traces, inverse_of: :implementation
end

class User < ActiveRecord::Base
  has_many :processed_texts, inverse_of: :user
end
