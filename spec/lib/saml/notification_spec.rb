require 'spec_helper'

class NotificationDummy
  include Saml::Notification

  notify_on :class_method, :instance_method

  def self.class_method(args)
    args
  end

  def instance_method(args)
    args
  end

  def without_notification(args)
    args
  end
end

describe Saml::Notification do
  describe 'notify_on' do
    subject { NotificationDummy }
    let(:callback) { Proc.new { |*args| @result = args } }
    let(:payload) { @result.try(:last) }

    it 'it allows a method to be wrapped with a notification' do
      expect(subject.notify_on).to eq [:class_method, :instance_method]
    end

    it 'creates a notification when a wrapped instance method is called' do
      ActiveSupport::Notifications.subscribed callback, 'instance_method.notification_dummy.saml' do
        NotificationDummy.new.instance_method('instance_method')
      end
      expect(payload).to eq 'instance_method'
    end

    it 'creates a notification when a wrapped class method is called' do
      ActiveSupport::Notifications.subscribed callback, 'class_method.notification_dummy.saml' do
        NotificationDummy.class_method('class_method')
      end
      expect(payload).to eq 'class_method'
    end

    it 'does not create a notification when a normal method is called' do
      ActiveSupport::Notifications.subscribed callback do
        NotificationDummy.new.without_notification('without_notification')
      end
      expect(payload).to be_blank
    end

  end
end
