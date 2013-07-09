module Saml
  module Elements
    class ContactPerson
      include Saml::Base

      tag 'ContactPerson'
      namespace 'md'

      module ContactTypes
        TECHNICAL = 'technical'
        SUPPORT = 'support'
        ADMINISTRATIVE = 'administrative'
        BILLING = 'billing'
        OTHER = 'other'

        ALL = [TECHNICAL, SUPPORT, ADMINISTRATIVE, BILLING, OTHER]
      end

      attribute :contact_type, String, :tag => "ContactType"

      element :company, String, :tag => "Company"
      element :given_name, String, :tag => "GivenName"
      element :sur_name, String, :tag => "SurName"

      has_many :email_addresses, String, :tag => "EmailAddress"
      has_many :telephone_numbers, String, :tag => "TelephoneNumber"

      validates :contact_type, :inclusion => ContactTypes::ALL

      validates :email_addresses, :telephone_numbers, :presence => true
    end
  end
end
