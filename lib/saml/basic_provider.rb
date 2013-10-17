module Saml
  class BasicProvider
    include Provider
    attr_accessor :entity_descriptor, :private_key, :type

    def initialize(entity_descriptor, private_key, type)
      @entity_descriptor = entity_descriptor
      @private_key       = private_key
      @type              = type
    end
  end
end
