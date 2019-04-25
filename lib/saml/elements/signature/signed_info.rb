module Saml
  module Elements
    class Signature
      class SignedInfo
        include Saml::Base

        tag "SignedInfo"
        namespace 'ds'

        element :canonicalization_method, CanonicalizationMethod
        element :signature_method, SignatureMethod
        element :reference, Reference

        def initialize(*args)
          @canonicalization_method = CanonicalizationMethod.new
          @signature_method        = SignatureMethod.new
          super(*args)
          options    = args.extract_options!
          @reference ||= Reference.new(uri: options.delete(:uri), digest_value: options.delete(:digest_value))
        end
      end
    end
  end
end
