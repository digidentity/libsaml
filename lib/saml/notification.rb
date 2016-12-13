module Saml
  module Notification
    extend ActiveSupport::Concern

    def notify(method, result)
      self.class.notify(method, result)
    end

    module ClassMethods
      def wrap_with_notification(method, instance_method)
        wrapper = <<-RUBY
          define_method "#{method}_with_notification" do |*args|
            notify "#{method}", send("#{method}_without_notification", *args)
          end

          alias_method "#{method}_without_notification", :#{method}
          alias_method :#{method}, "#{method}_with_notification"
        RUBY

        if instance_method
          class_eval wrapper
        else
          class_eval "class << self; #{wrapper}; end"
        end
      end

      def notify(method, result)
        class_name = self.name.demodulize.underscore
        ActiveSupport::Notifications.instrument "#{method}.#{class_name}.saml", result
        result
      end

      def notify_on(*options)
        options.present? ? @notify_on = options : @notify_on
      end

      def should_wrap?(name)
        @notify_on ||= []
        @exclude   ||= []

        return false if @notify_on.exclude?(name) || @exclude.include?(name.to_s)
        @exclude << "#{name}_with_notification"
        @exclude << "#{name}_without_notification"
        @exclude << "#{name}"
        true
      end

      def singleton_method_added(name)
        wrap_with_notification(name, false) if should_wrap?(name)
      end

      def method_added(name)
        wrap_with_notification(name, true) if should_wrap?(name)
      end
    end
  end
end
