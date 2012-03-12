
package be.ugent.zeus.resto.client.data.services;

import android.content.Intent;

/**
 *
 * @author Thomas Meire
 */
public class UpdaterService extends HTTPIntentService {

  public UpdaterService() {
    super("UpdaterService");
  }
  
  @Override
  protected void onHandleIntent(Intent intent) {
    String location = HYDRA_BASE_URL + "versions.xml";

    try {
      String versionsXML = fetch(location);
      
    } catch (Exception e) {}
  }
}
