# plugin.rb
# name: discourse-sms-verification
# about: Erzwingt SMS-Verifikation bei der Registrierung
# version: 0.1
# authors: Michael Braun
# url: https://github.com/Goaloge/discourse-sms-verification

enabled_site_setting :sms_verification_enabled

register_asset 'stylesheets/sms-verification.scss'

after_initialize do
  module ::SmsVerification
    PLUGIN_NAME = "discourse-sms-verification"
    
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace SmsVerification
    end
  end

  require_relative 'lib/verification_code'
  require_relative 'lib/sms_gateway'
  
  class SmsVerification::VerificationController < ::ApplicationController
    skip_before_action :redirect_to_login_if_required

    def send_code
      phone = params[:phone]
      return render json: { error: "Ungültige Telefonnummer" } unless valid_phone?(phone)
      
      code = SmsVerification::VerificationCode.generate(phone)
      if SmsVerification::SmsGateway.send(phone, "Ihr Verifikationscode: #{code}")
        render json: { success: true }
      else
        render json: { error: "SMS konnte nicht gesendet werden" }
      end
    end

    private

    def valid_phone?(phone)
      # Hier echte Validierung einbauen
      phone =~ /\A\+\d{8,15}\z/
    end
  end

  Discourse::Application.routes.append do
    post "/sms-verification/send" => "sms_verification/verification#send_code"
  end

  add_to_class(:user_creator, :require_sms_verification) do
    return if Rails.env.test?
    
    phone = @user.custom_fields['phone_number']
    unless SmsVerification::VerificationCode.verified?(phone)
      raise ActiveRecord::RecordInvalid.new("SMS nicht verifiziert")
    end
  end
end
