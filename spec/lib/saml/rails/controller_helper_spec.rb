require 'spec_helper'

describe Saml::Rails::ControllerHelper do
  class Controller
    extend Saml::Rails::ControllerHelper

    def self.before_filter(&block)
      new.run_callback(&block)
    end

    def run_callback(&block)
      instance_exec(&block)
    end

    def identity_provider
      Saml.provider('https://idp.example.com')
    end

    def current_provider
      Thread.current['provider']
    end
  end

  describe 'current_provider' do
    context 'with string' do
      it 'sets the current provider before all actions' do
        expect(Controller.current_provider('https://idp.example.com')).to be == Saml.provider('https://idp.example.com')
      end
    end

    context 'with symbol' do
      it 'sets the current provider' do
        Saml.current_provider = nil
        Controller.current_provider(:identity_provider)
        expect(Saml.current_provider).to be == Saml.provider('https://idp.example.com')
      end
    end

    context 'with block' do
      it 'sets the current provider' do
        Saml.current_provider = nil
        Controller.current_provider do
          Saml.current_provider = identity_provider
        end
        expect(Saml.current_provider).to be == Saml.provider('https://idp.example.com')
      end
    end
  end
end
