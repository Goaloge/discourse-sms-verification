module SmsVerification
  module SmsGateway
    class Fallback
      PROVIDERS = [Twilio].freeze

      def self.send(phone, message)
        last_error = nil
        
        PROVIDERS.each do |provider|
          begin
            return provider.send(phone, message)
          rescue => e
            last_error = e
            Rails.logger.error("#{provider} failed: #{e.message}")
          end
        end

        raise last_error || "No SMS providers available"
      end
    end
  end
end
