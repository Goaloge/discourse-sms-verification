describe SmsVerification::SmsGateway do
  describe ".send" do
    it "falls back to secondary provider" do
      SiteSetting.sms_gateway_provider = "twilio"
      allow(SmsVerification::SmsGateway::Twilio).to receive(:send).and_raise(StandardError)
      expect(SmsVerification::SmsGateway::Fallback).to receive(:send)
      described_class.send("+49123456789", "test")
    end
  end
end
