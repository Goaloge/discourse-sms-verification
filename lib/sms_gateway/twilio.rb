# plugins/discourse-sms-verification/lib/sms_gateway/twilio.rb
module SmsVerification
  module SmsGateway
    class Twilio
      def self.send(phone, message)
        account_sid = SiteSetting.sms_gateway_account
        auth_token = SiteSetting.sms_gateway_token
        from = SiteSetting.sms_gateway_sender

        client = ::Twilio::REST::Client.new(account_sid, auth_token)
        client.messages.create(
          from: from,
          to: phone,
          body: message
        )
        true
      rescue => e
        Rails.logger.error("Twilio error: #{e.message}")
        false
      end
    end
  end
end
