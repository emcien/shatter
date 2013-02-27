module Shatter
  module ArExtensions
    def shattered?
      !! self.uses_sharding
    end

    def shatter!
      self.uses_sharding = true
    end
  end
end
