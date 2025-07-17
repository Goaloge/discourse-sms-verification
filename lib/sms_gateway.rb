# lib/sms_gateway.rb
module SmsVerification
  class SmsGateway
    PROVIDERS = {
      twilio: {
        url: "https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json",
        params: ->(config, phone, msg) {
          {
            From: config[:from],
            To: phone,
            Body: msg
          }
        }
      },
      # Weitere Provider hier hinzufügen
    }

    def self.send(phone, message)
      provider = SiteSetting.sms_gateway_provider.downcase.to_sym
      config = {
        account: SiteSetting.sms_gateway_account,
        token: SiteSetting.sms_gateway_token,
        from: SiteSetting.sms_gateway_sender
      }

      endpoint = PROVIDERS[provider][:url] % config[:account]
      params = PROVIDERS[provider][:params].call(config, phone, message)

      response = Excon.post(
        endpoint,
        body: URI.encode_www_form(params),
        headers: { "Content-Type" => "application/x-www-form-urlencoded" },
        user: config[:account],
        password: config[:token]
      )

      response.status == 201
    rescue => e
      Rails.logger.error("SMS send error: #{e.message}")
      false
    end
  end
end
