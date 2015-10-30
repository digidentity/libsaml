module Saml
  module ComplexTypes
    module AdviceType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        require 'saml/assertion'

        has_many :assertions, ::Saml::Assertion
      end
    end
  end
end
