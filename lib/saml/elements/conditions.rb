module Saml
  module Elements
    class Conditions
      include Saml::Base

      tag "Conditions"
      namespace 'saml'

      attribute :not_before, Time, :tag => "NotBefore", :on_save => lambda { |val| val.utc.xmlschema }
      attribute :not_on_or_after, Time, :tag => "NotOnOrAfter", :on_save => lambda { |val| val.utc.xmlschema }

      has_one :audience_restriction, Saml::Elements::AudienceRestriction

      def initialize(*args)
        options = args.extract_options!
        @audience_restriction = Saml::Elements::AudienceRestriction.new(:audience => options.delete(:audience)) if options[:audience]
        self.not_before       = Time.now - Saml::Config.max_issue_instant_offset.minutes
        self.not_on_or_after  = Time.now + Saml::Config.max_issue_instant_offset.minutes
        super(*(args << options))
      end

    end
  end
end
