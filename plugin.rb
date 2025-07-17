# plugin.rb
# name: discourse-sms-verification
# about: Erzwingt SMS-Verifikation bei der Registrierung
# version: 1.0
# authors: Michael Braun
# url: https://github.com/Goaloge/discourse-sms-verification
# transpile_js: true

enabled_site_setting :sms_verification_enabled

register_asset 'stylesheets/sms-verification.scss'

register_svg_icon "mobile-alt" if respond_to?(:register_svg_icon)

after_initialize do
  # Engine für Namespacing
  module ::SmsVerification
    PLUGIN_NAME = "discourse-sms-verification"
    
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace SmsVerification
    end
  end

  # Abhängigkeiten laden
  require_relative 'lib/verification_code'
  require_relative 'lib/sms_gateway'
  require_relative 'lib/sms_gateway/twilio'
  require_relative 'lib/sms_gateway/messagebird'
  require_relative 'lib/sms_gateway/fallback'
  require_relative 'lib/admin/sms_verification_admin_controller'

  # Rate Limiting
  RateLimiter.register_limiters! do
    [
      RateLimiter.new(
        "sms_verification_per_ip",
        3,
        1.hour,
        apply_to: [:send_code, :verify],
        per: :ip
      )
    ]
  end

  # Controller für SMS-Verifikation
  class SmsVerification::VerificationController < ::ApplicationController
    skip_before_action :redirect_to_login_if_required
    before_action :ensure_sms_enabled

    def send_code
      phone = normalize_phone(params[:phone])
      return render_error("Invalid phone format") unless valid_phone?(phone)
      
      code = SmsVerification::VerificationCode.generate(phone)
      if SmsVerification::SmsGateway.send(phone, I18n.t("sms_verification.sms_body", code: code, site_name: SiteSetting.title))
        render json: { success: true }
      else
        render json: { error: I18n.t("sms_verification.send_error") }, status: 502
      end
    end

    def verify
      phone = normalize_phone(params[:phone])
      code = params[:code]
      
      if SmsVerification::VerificationCode.verify(phone, code)
        SmsVerification::VerificationCode.mark_verified(phone)
        render json: { success: true }
      else
        render json: { error: I18n.t("sms_verification.invalid_code") }, status: 422
      end
    end

    private

    def ensure_sms_enabled
      raise Discourse::NotFound unless SiteSetting.sms_verification_enabled
    end

    def normalize_phone(phone)
      phone.gsub(/\s+/, '').sub(/\A0/, "+49")
    end

    def valid_phone?(phone)
      phone =~ /\A\+\d{8,15}\z/
    end
  end

  # User-Custom-Field-Validierung
  add_to_class(:user, :phone_number) do
    custom_fields['phone_number']
  end

  add_to_class(:user_creator, :enforce_sms_verification) do
    return if Rails.env.test? || @user.staff?
    
    unless SmsVerification::VerificationCode.verified?(@user.phone_number)
      raise ActiveRecord::RecordInvalid.new(I18n.t("sms_verification.not_verified"))
    end
  end

  # Admin-Routen
  Discourse::Application.routes.append do
    namespace :admin, constraints: StaffConstraint.new do
      get "sms-verification" => "sms_verification_admin#index"
    end
    
    post "/sms-verification/send" => "sms_verification/verification#send_code"
    post "/sms-verification/verify" => "sms_verification/verification#verify"
  end
end
