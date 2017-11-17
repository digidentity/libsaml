require 'zlib'
require 'base64'

module Saml
  class Encoding

    def self.encode_64 string
      Base64.strict_encode64(string)
    end

    def self.decode_64 base64_string
      Base64.decode64 base64_string
    end

    def self.encode_gzip string
      Zlib::Deflate.deflate(string, 9)[2..-5]
    end

    def self.decode_gzip gzip_binary_string
      # Adding a - sign to MAX_WBITS makes zlib ignore the zlib headers
      inflate(gzip_binary_string, -Zlib::MAX_WBITS)
    rescue ::Zlib::DataError
      inflate(gzip_binary_string) rescue nil
    end

    def self.inflate gzip_binary_string, max_bits=nil
      zstream = Zlib::Inflate.new(max_bits)
      begin
        zstream.inflate(gzip_binary_string)
      ensure
        zstream.close
      end
    end
  end
end
