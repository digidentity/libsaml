module Saml
  class BasicProvider
    include Provider
    attr_accessor :entity_descriptor, :private_key, :type

    def initialize(entity_descriptor, private_key, type, signing_key)
      @entity_descriptor = entity_descriptor
      @private_key       = private_key
      @type              = type
      @signing_key       = signing_key
    end
  end
end
