require 'spec_helper'

describe Saml::Rails::ControllerHelper do
  ApplicationController = Struct.new(:controller) do
    def self.before_filter(*args)
    end

    attr_accessor :headers

    def initialize
      @headers = Hash.new
    end

    def response
      self
    end
  end

  class Controller < ApplicationController
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

  describe '#set_response_headers' do
    let(:controller)  { Controller.new }

    before { controller.set_response_headers }

    it 'includes the Cache-Control header' do
      expect(controller.headers['Cache-Control']).to eql 'no-cache, no-store'
    end

    it 'includes the Pragma header' do
      expect(controller.headers['Pragma']).to eql 'no-cache'
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

  describe '#current_store' do
    it 'sets the current store' do
      Saml.current_store = nil
      Controller.current_store(:file)
      expect(Saml.current_store).to be == Saml::Config.registered_stores[:file]
    end
  end
end
