import Controller from "@ember/controller";
import { inject as service } from "@ember/service";

export default class AdminSmsVerificationController extends Controller {
  @service ajax;

  @action
  async refreshStats() {
    const data = await this.ajax.request("/admin/sms-verification.json");
    this.set("stats", data);
  }
}
