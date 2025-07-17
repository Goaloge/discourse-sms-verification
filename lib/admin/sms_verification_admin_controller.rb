module Admin
  class SmsVerificationAdminController < ::Admin::AdminController
    requires_plugin 'discourse-sms-verification'

    def index
      render json: { success: true }
    end
  end
end
