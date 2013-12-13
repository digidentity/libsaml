require 'saml/elements/signature/inclusive_namespaces'
require 'saml/elements/signature/transform'
require 'saml/elements/signature/transforms'
require 'saml/elements/signature/digest_method'
require 'saml/elements/signature/reference'
require 'saml/elements/signature/signature_method'
require 'saml/elements/signature/canonicalization_method'
require 'saml/elements/signature/signed_info'
require 'saml/elements/key_info'

module Saml
  module Elements
    class Signature
      include Saml::Base

      tag "Signature"
      register_namespace 'ds', Saml::XML_DSIG_NAMESPACE
      namespace 'ds'

      has_one :signed_info, SignedInfo
      element :signature_value, String, :tag => "SignatureValue", :state_when_nil => true
      has_one :key_info, KeyInfo

      def initialize(*args)
        super(*args)
        options       = args.extract_options!
        @signed_info  ||= SignedInfo.new(:uri => options.delete(:uri), :digest_value => options.delete(:digest_value))
        @key_info     ||= KeyInfo.new
      end

      def key_name
        @key_info.try(:key_name)
      end
    end
  end
end
