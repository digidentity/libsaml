module Saml
  module Elements
    class Organization
      include Saml::Base

      tag 'Organization'
      namespace 'md'

      has_many :organization_names, Saml::Elements::OrganizationName
      has_many :organization_display_names, Saml::Elements::OrganizationDisplayName
      has_many :organization_urls, Saml::Elements::OrganizationUrl

      validates :organization_names, :organization_display_names, :organization_urls, presence: true
    end
  end
end
