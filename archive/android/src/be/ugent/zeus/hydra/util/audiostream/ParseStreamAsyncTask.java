/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package be.ugent.zeus.hydra.util.audiostream;

import android.os.AsyncTask;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 *
 * @author silox
 */
public class ParseStreamAsyncTask extends AsyncTask<String, Void, String> {

    MusicService musicService;

    public ParseStreamAsyncTask(MusicService musicService) {
        this.musicService = musicService;
    }

    @Override
    protected String doInBackground(String... params) {
        String line;

        try {
            URL urlPage = new URL(params[0]);
            HttpURLConnection connection = (HttpURLConnection) urlPage.openConnection();
            InputStream inputStream = connection.getInputStream();
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(inputStream));

            StringBuilder stringBuffer = new StringBuilder();

            while ((line = bufferedReader.readLine()) != null) {
                if (line.contains("http")) {
                    connection.disconnect();
                    bufferedReader.close();
                    inputStream.close();
                    return line;
                }
                stringBuffer.append(line);
            }

            connection.disconnect();
            bufferedReader.close();
            inputStream.close();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    protected void onPostExecute(String result) {
        musicService.playmp3(result);
    }
}
