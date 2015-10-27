module Saml
  module Elements
    class Subject
      include Saml::Base

      tag "Subject"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      has_one :_name_id, Saml::Elements::NameId
      has_one :encrypted_id, Saml::Elements::EncryptedID

      has_many :subject_confirmation, Saml::Elements::SubjectConfirmation

      validates :name_id, :subject_confirmation, :presence => true

      def initialize(*args)
        options               = args.extract_options!
        @_name_id             = Saml::Elements::NameId.new(format: options.delete(:name_id_format),
                                                           value:  options.delete(:name_id))
        @subject_confirmation = Saml::Elements::SubjectConfirmation.new(recipient:      options.delete(:recipient),
                                                                        in_response_to: options.delete(:in_response_to))
        super(*(args << options))
      end

      def name_id
        @_name_id.value
      end

      def name_id=(value)
        @_name_id.value = value
      end

      def name_id_format
        @_name_id.format
      end
    end
  end
end
