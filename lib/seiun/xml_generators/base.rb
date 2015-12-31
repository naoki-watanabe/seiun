module Seiun
  module XMLGenerators
    class Base
      def initialize(callback: nil)
        @callback = callback
        @rexml_doc = REXML::Document.new
        @rexml_doc << REXML::XMLDecl.new('1.0', 'UTF-8')
      end

      def to_s
        io = StringIO.new
        rexml_doc.write(io)
        io.rewind
        io.read
      end

      private

      def rexml_doc
        @rexml_doc
      end
    end
  end
end
