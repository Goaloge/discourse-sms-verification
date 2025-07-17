module Admin
  class SmsVerificationAdminController < ::Admin::AdminController
    def index
      render json: { success: true }
    end
  end
end
