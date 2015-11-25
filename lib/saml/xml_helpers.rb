
module Saml
  module XMLHelpers
    extend ActiveSupport::Concern

    def add_signature
      self.signature = Saml::Elements::Signature.new(uri: "##{self._id}")
      x509certificate = OpenSSL::X509::Certificate.new(provider.certificate) rescue nil
      self.signature.key_info = Saml::Elements::KeyInfo.new(x509certificate.to_pem) if x509certificate
    end

    def to_xml(*args)
      options                              = args.extract_options!
      builder, default_namespace, instruct = args
      instruct                             = true if instruct.nil?

      write_xml            = builder.nil? ? true : false
      builder              ||= Nokogiri::XML::Builder.new
      builder.doc.encoding = "UTF-8"
      result = if use_parsed? && respond_to?(:xml_value)
        builder << xml_value
        builder
      else
        super(builder, default_namespace)
      end

      if write_xml
        instruct ? result.to_xml(nokogiri_options(options)) : result.doc.root
      else
        result
      end
    end

    def to_soap(options = {})
      builder = Nokogiri::XML::Builder.new
      body    = self.to_xml(builder)

      builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8")
      builder.Envelope(:'xmlns:soapenv' => "http://schemas.xmlsoap.org/soap/envelope/") do |xml|
        builder.parent.namespace = builder.parent.namespace_definitions.find { |n| n.prefix == 'soapenv' }
        builder.Body do
          builder.parent.add_child body.doc.root
        end
      end
      builder.to_xml(nokogiri_options(options))
    end

    private

    def nokogiri_options(options)
      nokogiri_options             = {
          save_with: Nokogiri::XML::Node::SaveOptions::AS_XML
      }
      nokogiri_options[:save_with] |= Nokogiri::XML::Node::SaveOptions::FORMAT if options[:formatted]
      nokogiri_options
    end
  end
end
