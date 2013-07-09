module Saml
  module Elements
    class SubjectConfirmation
      include Saml::Base

      class Methods
        BEARER = "urn:oasis:names:tc:SAML:2.0:cm:bearer"
      end

      tag "SubjectConfirmation"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      attribute :_method, String, :tag => 'Method'

      has_many :subject_confirmation_data, Saml::Elements::SubjectConfirmationData

      validates :_method, :presence => true


      def initialize(*args)
        options                    = args.extract_options!
        @subject_confirmation_data = Saml::Elements::SubjectConfirmationData.new(:recipient      => options.delete(:recipient),
                                                                                 :in_response_to => options.delete(:in_response_to))
        super(*(args << options))
        @_method ||= Methods::BEARER
      end
    end
  end
end
