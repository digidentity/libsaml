module Saml
  class BasicProvider
    include Provider
    attr_accessor :entity_descriptor, :encryption_key, :type

    def initialize(entity_descriptor, encryption_key, type, signing_key)
      @entity_descriptor = entity_descriptor
      @encryption_key    = encryption_key
      @type              = type
      @signing_key       = signing_key
    end
  end
end
