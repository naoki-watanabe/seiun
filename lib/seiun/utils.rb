module Seiun
  class Utils
    class << self
      def camelize(str)
        str.to_s.gsub(/_([a-z])/){|match| $1.upcase }
      end

      def underscore(str)
        str.to_s.gsub(/([a-z0-9])([A-Z])/){|match| "#{$1}_#{$2.downcase}" }
      end

      def parsable_date?(str)
        str.to_s =~ /^[1-4][0-9]{3}-(?:0[1-9]|1[012])-(?:0[1-9]|[12][0-9]|3[01])$/
      end

      def parsable_time?(str)
        str.to_s =~ /^[1-4][0-9]{3}-(?:0[1-9]|1[012])-(?:0[1-9]|[12][0-9]|3[01])T(?:[01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]/
      end
    end
  end
end
