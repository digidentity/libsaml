module Saml
  module Elements
    class Subject
      include Saml::Base

      tag "Subject"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      has_one :_name_id, Saml::Elements::NameId
      has_one :encrypted_id, Saml::Elements::EncryptedID

      has_many :subject_confirmations, Saml::Elements::SubjectConfirmation

      validates :subject_confirmations, presence: true
      validate :check_identifier

      def initialize(*args)
        options               = args.extract_options!
        if options[:name_id].present?
          @_name_id             = Saml::Elements::NameId.new(format: options.delete(:name_id_format),
                                                             value:  options.delete(:name_id))
        end
        @subject_confirmations = [Saml::Elements::SubjectConfirmation.new(recipient:      options.delete(:recipient),
                                                                          in_response_to: options.delete(:in_response_to))]
        super(*(args << options))
      end

      def name_id
        @_name_id.try(:value)
      end

      def name_id=(value)
        @_name_id.value = value if @_name_id
      end

      def name_id_format
        @_name_id.try(:format)
      end

      def subject_confirmation
        subject_confirmations.first
      end

      def subject_confirmation=(subject_confirmation)
        self.subject_confirmations = [subject_confirmation]
      end

      private

      def check_identifier
        errors.add(:identifiers, :one_identifier_mandatory) if identifiers.blank?
        errors.add(:identifiers, :one_identifier_allowed)   if identifiers.size > 1
      end

      def identifiers
        [_name_id, encrypted_id].compact
      end

    end
  end
end
