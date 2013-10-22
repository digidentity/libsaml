module Saml
  module Rails
    module ControllerHelper
      def current_provider(entity_id_or_method = nil, &block)
        if block_given?
          before_action &block
        else
          case entity_id_or_method
            when Symbol
              before_action { Saml.current_provider = send(entity_id_or_method) }
            else
              before_action { Saml.current_provider = Saml.provider("#{entity_id_or_method}") }
          end
        end
      end

      def current_store(store_or_symbol = nil)
        case store_or_symbol
          when Symbol
            before_action { Saml.current_store = store_or_symbol }
          else
            before_action do
              Saml::Config.register_store klass.name.underscore, klass_or_symbol
              Saml.current_store = klass.name.underscore
            end
        end
      end
    end
  end
end
