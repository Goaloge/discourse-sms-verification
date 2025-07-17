# lib/verification_code.rb
module SmsVerification
  class VerificationCode
    def self.generate(phone)
      code = rand(100_000..999_999).to_s
      Discourse.redis.setex("sms_verify:#{phone}", 600, code) # 10 Minuten Gültigkeit
      code
    end

    def self.verify(phone, attempt)
      stored = Discourse.redis.get("sms_verify:#{phone}")
      return false if stored.nil?
      stored == attempt
    end

    def self.verified?(phone)
      Discourse.redis.exists?("sms_verified:#{phone}")
    end

    def self.mark_verified(phone)
      Discourse.redis.setex("sms_verified:#{phone}", 86400, "1") # 24h gültig
    end
  end
end
