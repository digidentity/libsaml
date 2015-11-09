module Saml
  module ComplexTypes
    module AdviceType
      extend ActiveSupport::Concern
      include Saml::Base

      included do
        require 'saml/assertion'

        has_many :assertions, ::Saml::Assertion
        has_many :assertion_id_refs, String, tag: 'AssertionIDRef'
      end
    end
  end
end
