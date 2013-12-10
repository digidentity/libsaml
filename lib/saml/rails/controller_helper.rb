module Saml
  module Rails
    module ControllerHelper
      def current_provider(entity_id_or_method = nil, &block)
        if block_given?
          before_filter &block
        else
          case entity_id_or_method
            when Symbol
              before_filter { Saml.current_provider = send(entity_id_or_method) }
            else
              before_filter { Saml.current_provider = Saml.provider("#{entity_id_or_method}") }
          end
        end
      end

      def current_store(store)
        before_filter { Saml.current_store = store }
      end
    end
  end
end
