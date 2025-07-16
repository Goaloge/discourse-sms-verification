require 'twilio-ruby'

module SmsSender
  def self.send_code(phone_number, code)
    account_sid = SiteSetting.twilio_account_sid
    auth_token = SiteSetting.twilio_auth_token
    from_number = SiteSetting.twilio_from_number

    begin
      client = Twilio::REST::Client.new(account_sid, auth_token)

      message = client.messages.create(
        from: from_number,
        to: phone_number,
        body: "Dein Verifizierungscode lautet: #{code}"
      )

      Rails.logger.info("Twilio SMS gesendet an #{phone_number}: SID=#{message.sid}")
    rescue => e
      Rails.logger.error("Twilio-SMS-Fehler: #{e.message}")
    end
  end
end
