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
      subject.notify_on.should == [:class_method, :instance_method]
    end

    it 'creates a notification when a wrapped instance method is called' do
      ActiveSupport::Notifications.subscribed callback, 'instance_method.notification_dummy.saml' do
        NotificationDummy.new.instance_method('instance_method')
      end
      payload.should == 'instance_method'
    end

    it 'creates a notification when a wrapped class method is called' do
      ActiveSupport::Notifications.subscribed callback, 'class_method.notification_dummy.saml' do
        NotificationDummy.class_method('class_method')
      end
      payload.should == 'class_method'
    end

    it 'does not create a notification when a normal method is called' do
      ActiveSupport::Notifications.subscribed callback do
        NotificationDummy.new.without_notification('without_notification')
      end
      payload.should be_blank
    end

  end
end
