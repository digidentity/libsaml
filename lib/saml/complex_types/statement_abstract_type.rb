module Saml
  module ComplexTypes
    class StatementAbstractType
      include HappyMapper

      register_namespace 'xsi', 'http://www.w3.org/2001/XMLSchema-instance'

      tag 'Statement'
      namespace 'saml'

      attribute :type, String, tag: 'xsi:type'

      def self.register_type(type, klass)
        types[type] = klass
      end

      def self.types
        @types ||= {}
      end

      # TODO: handle multiple statements with different types
      def self.parse(xml, options = {})
        statements = Array(super)
        statements.collect do |statement|
          if (type = types[statement.type])
            type.parse(xml, options.merge(single: true))
          else
            statement
          end
        end
      end
    end
  end
end
