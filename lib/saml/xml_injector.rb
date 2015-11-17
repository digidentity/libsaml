module Saml
  class XmlInjector
    attr_accessor :document

    def initialize(document)
      @document = if document.kind_of?(Nokogiri::XML::Document)
        document
      else
        Nokogiri::XML(document, nil, nil, Nokogiri::XML::ParseOptions::STRICT)
      end
    end

    def inject_xml(xml_or_fragment, options)
      fragment = if xml_or_fragment.kind_of?(Nokogiri::XML::DocumentFragment)
        xml_or_fragment
      else
        Nokogiri::XML::DocumentFragment.parse(xml_or_fragment)
      end

      @document.at_xpath(options[:xpath]).add_child(fragment)
    end

    def to_xml
      @document.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    end
  end
end
