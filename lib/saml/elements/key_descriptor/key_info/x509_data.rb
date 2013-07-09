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
              unless cert =~ /-----BEGIN CERTIFICATE-----/
                cert = cert.gsub(/\n/, '')
                cert = "-----BEGIN CERTIFICATE-----\n#{cert.gsub(/(.{1,64})/, "\\1\n")}-----END CERTIFICATE-----"
              end
              @x509certificate = OpenSSL::X509::Certificate.new(cert)
            end
          rescue OpenSSL::X509::CertificateError => e
            nil
          end
        end
      end
    end
  end
end
