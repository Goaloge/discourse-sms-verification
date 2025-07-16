import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "sms-verification",
  initialize(container) {
    withPluginApi("0.8.7", api => {
      api.modifySignUpFields(fields => {
        fields.push({
          id: "phone_number",
          label: "Telefonnummer (für SMS-Verifizierung)",
          type: "text",
          required: true
        });
      });
    });
  }
};
