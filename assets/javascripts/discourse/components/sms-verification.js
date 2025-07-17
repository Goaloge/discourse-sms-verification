import Component from "@glimmer/component";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class SmsVerification extends Component {
  @service siteSettings;
  @tracked phone = "";
  @tracked code = "";
  @tracked codeSent = false;
  @tracked sending = false;
  @tracked verifying = false;

  @action
  async sendCode() {
    this.sending = true;
    
    try {
      const response = await fetch("/sms-verification/send", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone: this.phone })
      });

      if (response.ok) {
        this.codeSent = true;
      } else {
        const error = await response.json();
        throw new Error(error.error);
      }
    } catch (e) {
      alert(`Fehler: ${e.message}`);
    } finally {
      this.sending = false;
    }
  }

  @action
  async verifyCode() {
    this.verifying = true;
    
    try {
      const response = await fetch("/sms-verification/verify", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
          phone: this.phone, 
          code: this.code 
        })
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error);
      }
      
      // Verifikation erfolgreich
      this.args.model.set("smsVerified", true);
    } catch (e) {
      alert(`Verifikationsfehler: ${e.message}`);
    } finally {
      this.verifying = false;
    }
  }
}
