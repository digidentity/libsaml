module Saml
  module Elements
    class KeyDescriptor
      class KeyInfo
        class X509Data
          include Saml::Base

          tag 'X509Data'
          namespace 'ds'

          element :x509certificate, String, :tag => "X509Certificate", :on_save => lambda { |c| c.present? ? Base64.encode64(c.to_der) : "" }

          validates :x509certificate, :presence => true

          def initialize(cert = nil)
            self.x509certificate = cert
          end

          def x509certificate=(cert)
            if cert.present?
              if cert =~ /-----BEGIN CERTIFICATE-----/
                @x509certificate = OpenSSL::X509::Certificate.new(cert)
              else
                @x509certificate = OpenSSL::X509::Certificate.new(Base64.decode64(cert))
              end
            end
          rescue OpenSSL::X509::CertificateError => e
            nil
          end
        end
      end
    end
  end
end
