require 'rails_helper'

describe SmsVerification::VerificationController do
  before do
    SiteSetting.sms_verification_enabled = true
    SiteSetting.sms_gateway_provider = "test"
  end

  describe "POST /sms-verification/send" do
    it "blocks invalid phone numbers" do
      post "/sms-verification/send.json", params: { phone: "123" }
      expect(response.status).to eq(422)
    end

    it "rate limits requests" do
      4.times { post "/sms-verification/send.json", params: { phone: "+49123456789" } }
      expect(response.status).to eq(429)
    end
  end
end
