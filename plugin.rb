# name: discourse-sms-verification
# about: Plugin zur SMS-Verifizierung neuer Benutzer via Twilio
# version: 0.1
# authors: Michael Braun
# url: https://github.com/dein/plugin

enabled_site_setting :sms_verification_enabled

after_initialize do
  module ::SmsVerification
    class Engine < ::Rails::Engine
      engine_name "sms_verification"
      isolate_namespace SmsVerification
    end
  end

  require_dependency 'user'
  begin
  require 'twilio-ruby'
  require_relative 'lib/sms_sender'
rescue LoadError => e
  Rails.logger.warn("twilio-ruby konnte nicht geladen werden: #{e}")
end


  on(:user_created) do |user|
    if SiteSetting.sms_verification_enabled
      phone = user.custom_fields["phone_number"]
      code = rand(100000..999999).to_s

      user.custom_fields["sms_code"] = code
      user.custom_fields["sms_verified"] = "false"
      user.save_custom_fields

      SmsSender.send_code(phone, code)
    end
  end

  DiscourseEvent.on(:user_logged_in) do |user|
    if user.custom_fields["sms_verified"] != "true"
      # Optional: Hinweis anzeigen oder Weiterleitung zur Verifizierungsseite verlinken
    end
  end

  module ::SmsVerification
    class VerifyController < ::ApplicationController
      requires_plugin 'discourse-sms-verification'

      before_action :ensure_logged_in

      def confirm
        code = params[:code]
        user = current_user

        if user.custom_fields["sms_code"] == code
          user.custom_fields["sms_verified"] = "true"
          user.save_custom_fields
          render json: { success: true }
        else
          render json: { success: false, error: "Falscher Code" }
        end
      end
    end
  end

  SmsVerification::Engine.routes.draw do
    post "/verify" => "verify#confirm"
  end

  Discourse::Application.routes.append do
    mount ::SmsVerification::Engine, at: "/sms-verification"
  end

  # Register frontend assets for verification page
  register_asset "javascripts/discourse/routes/sms-verification-verify.js"
  register_asset "javascripts/discourse/templates/sms-verification-verify.hbs"
  register_asset "javascripts/discourse/controllers/sms-verification-verify.js"
  register_asset "javascripts/discourse/initializers/sms-verification.js"

end
