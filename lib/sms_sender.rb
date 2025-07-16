require 'twilio-ruby'

module SmsSender
  def self.send_code(phone_number, code)
    account_sid = SiteSetting.twilio_account_sid
    auth_token = SiteSetting.twilio_auth_token
    from_number = SiteSetting.twilio_from_number

    # Sicherheitsprüfung: Nicht senden, wenn Daten fehlen
    if account_sid.blank? || auth_token.blank? || from_number.blank?
      Rails.logger.warn("Twilio-SMS nicht gesendet: API-Zugangsdaten fehlen.")
      return
    end

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
