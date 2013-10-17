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
    end
  end
end
