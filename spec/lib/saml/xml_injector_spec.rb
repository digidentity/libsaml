require 'spec_helper'

describe Saml::XmlInjector do
  it 'injects xml at the given xpath' do
    xml = <<-XML.strip_heredoc
      <foo>
        <bar>Test</bar>
      </foo>
    XML
    inject_xml = "<baz><bar>Test</bar></baz>"

    expected = <<-XML.strip_heredoc
      <?xml version=\"1.0\"?>
      <foo>
        <bar>Test</bar>
      <baz><bar>Test</bar></baz></foo>
    XML

    injector = Saml::XmlInjector.new(xml)
    injector.inject_xml(inject_xml, xpath: '//foo')

    expect(injector.to_xml).to eq expected
  end
end
