module Saml
  module Elements
    class Subject
      include Saml::Base

      tag "Subject"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      element :name_id, String, :tag => "NameID"

      has_many :subject_confirmation, Saml::Elements::SubjectConfirmation

      validates :name_id, :presence => true

      def initialize(*args)
        options               = args.extract_options!
        @subject_confirmation = Saml::Elements::SubjectConfirmation.new(:recipient      => options.delete(:recipient),
                                                                        :in_response_to => options.delete(:in_response_to))
        super(*(args << options))
      end
    end
  end
end
