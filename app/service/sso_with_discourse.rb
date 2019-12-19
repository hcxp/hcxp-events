require 'securerandom'

# implementation of "Using Discourse as a SSO provider"
# refenrece: https://meta.discourse.org/t/using-discourse-as-a-sso-provider/32974
module SsoWithDiscourse
  # mattr_accessor :secret
  # @@secret = Rails.application.config.discourse_sso_secret

  # mattr_accessor :url
  # @@url = Rails.application.config.discourse_sso_url

  # Exceptions
  # class SecretNotSetError < ArgumentError; end
  # class UrlNotSetError < ArgumentError; end
  # class ReturnUrlNotSetError < ArgumentError; end
  class Sso
    attr_accessor :nonce, :user_info, :status, :message, :secret, :url, :return_url

    def initialize(opts = {})
      @secret     = opts[:secret] || ENV['DISCOURSE_SSO_SECRET']
      @url        = opts[:url] || ENV['DISCOURSE_SSO_URL']
      @return_url = opts[:return_url]

      generate_nonce!
    end

    def generate_nonce!
      @nonce = SecureRandom.hex
    end

    def request_url
      # validate_config!
      "#{url}?sso=#{url_encoded_payload}&sig=#{hex_signature}"
    end

    def parse(params)
      # params should be something that looks like:
      # { sso: "xxxxxx", sig: "yyyyyy" }
      if get_hmac_hex_string(params[:sso]) == params[:sig]
        if base64? params[:sso]
          decoded_hash = Rack::Utils.parse_query(Base64.decode64(params[:sso]))
          decoded_hash.symbolize_keys!
          if decoded_hash[:nonce] == @nonce
            @status = "success"
            decoded_hash.delete(:nonce)
            @user_info = decoded_hash
            @message = "SSO verification passed."
            return self
          else
            @status = "error"
            @user_info = nil
            @message = "SSO verification failed. Nonce mismatch."
            return nil
          end
        else
          @status = "error"
          @user_info = nil
          @message = "The sso string is supposed to be encoded in Base64."
          return nil
        end
      else
        @status = "error"
        @user_info = nil
        @message = "HMAC mismatch. The message may have been tampered with."
        return nil
      end
    end

    private

    def raw_payload
      unless @nonce
        raise "You must generate a nonce by calling generate_nonce! first."
      else
        "nonce=#{ @nonce }&return_sso_url=#{ return_url }"
      end
    end

    def base64_encoded_payload
      Base64.encode64(raw_payload)
    end

    def url_encoded_payload
      URI.escape(base64_encoded_payload)
    end

    def hex_signature
      get_hmac_hex_string base64_encoded_payload
    end

    def get_hmac_hex_string payload
      OpenSSL::HMAC.hexdigest("sha256", secret, payload)
    end

    def base64? data
      !(data =~ /[^a-zA-Z0-9=\r\n\/+]/m)
    end
  end
end
