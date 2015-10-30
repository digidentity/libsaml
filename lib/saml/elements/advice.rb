module Saml
  module Elements
    class Advice
      include ComplexTypes::AdviceType

      tag 'Advice'
      namespace 'saml'
    end
  end
end
