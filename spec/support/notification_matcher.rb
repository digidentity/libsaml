module Saml
  module Matchers
    class NotificationMatcher
      def initialize(*event_names)
        @event_names = event_names
      end

      def matches?(block_to_test)
        @result = []
        result = ->(*args) { @result << args }
        ActiveSupport::Notifications.subscribed result, /#{@event_names.join('|')}/ do
          block_to_test.call
        end

        @event_names.collect.with_index do |event_name, index|
          next(false) unless (result = @result[index])
          result.first.to_s.start_with?(event_name) && result.last.present?
        end.all?
      end

      def failure_message
        "Notification(s) #{@event_names.join(' and ')} not created"
      end
    end

    def notify_with(*event_names)
      Saml::Matchers::NotificationMatcher.new(*event_names)
    end
  end
end
RSpec.configure do |config|
  config.include Saml::Matchers
end
