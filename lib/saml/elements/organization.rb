module Saml
  module Elements
    class Organization
      include Saml::Base

      tag 'Organization'
      namespace 'md'

      has_many :organization_names, String, :tag => "OrganizationName"
      has_many :organization_display_names, String, :tag => "OrganizationDisplayName"
      has_many :organization_urls, String, :tag => "OrganizationURL"

      validates :organization_names, :organization_display_names, :organization_urls, :presence => true
    end
  end
end
