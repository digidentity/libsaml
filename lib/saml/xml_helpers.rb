module Saml
  module XMLHelpers
    extend ActiveSupport::Concern

    def add_signature
      self.signature = Saml::Elements::Signature.new(uri: "##{self._id}")
      x509certificate = OpenSSL::X509::Certificate.new(provider.certificate) rescue nil
      self.signature.key_info = Saml::Elements::KeyDescriptor::KeyInfo.new(x509certificate.to_pem) if x509certificate
    end

    def to_xml(builder = nil, default_namespace = nil, instruct = true)
      write_xml            = builder.nil? ? true : false
      builder              ||= Nokogiri::XML::Builder.new
      builder.doc.encoding = "UTF-8"
      result               = super(builder, default_namespace)
      if write_xml
        instruct ? result.to_xml : result.doc.root
      else
        result
      end

    end

    def to_soap
      builder = Nokogiri::XML::Builder.new
      body    = self.to_xml(builder)

      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8")
      builder.Envelope(:'xmlns:soapenv' => "http://schemas.xmlsoap.org/soap/envelope/",
                       :'xmlns:xsd'     => "http://www.w3.org/2001/XMLSchema",
                       :'xmlns:xsi'     => "http://www.w3.org/2001/XMLSchema-instance") do |xml|
        builder.parent.namespace = builder.parent.namespace_definitions.find { |n| n.prefix == 'soapenv' }
        builder.Body do
          builder.parent.add_child body.doc.root
        end
      end
      builder.to_xml
    end
  end
end
