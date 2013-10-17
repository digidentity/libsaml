module Saml
  class NullProvider
    include Provider

    def entity_id
      nil
    end
  end
end
