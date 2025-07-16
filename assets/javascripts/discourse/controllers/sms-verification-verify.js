import Controller from "@ember/controller";
import { ajax } from "discourse/lib/ajax";
import { action } from "@ember/object";

export default class SmsVerificationVerifyController extends Controller {
  @action
  verifyCode() {
    const code = document.getElementById("verification-code").value;

    ajax("/sms-verification/verify", {
      method: "POST",
      data: { code },
    })
      .then((result) => {
        if (result.success) {
          document.getElementById("verification-status").innerText =
            "✅ Verifizierung erfolgreich! Du bist freigeschaltet.";
        } else {
          document.getElementById("verification-status").innerText =
            "❌ Falscher Code. Bitte versuche es erneut.";
        }
      })
      .catch(() => {
        document.getElementById("verification-status").innerText =
          "❌ Fehler bei der Anfrage.";
      });
  }
}
