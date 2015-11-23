require 'xmlmapper'

module Saml
  module ComplexTypes
    module StatusResponseType
      extend ActiveSupport::Concern

      include RequestAbstractType

      included do
        attribute :in_response_to, String, :tag => 'InResponseTo'
        has_one :status, Saml::Elements::Status

        validates :in_response_to, :status, :presence => true
      end

      def initialize(*args)
        options = args.extract_options!
        @status = Saml::Elements::Status.new(status_code: Saml::Elements::StatusCode.new(value: options.delete(:status_value),
                                                                                         sub_status_value: options.delete(:sub_status_value)))
        @status.status_detail = Saml::Elements::StatusDetail.new(status_value: options.delete(:status_detail)) if options[:status_detail]
        super(*(args << options))
      end

      def success?
        status.status_code.success?
      end
    end
  end
end
