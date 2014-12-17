package de.guj.ems.mobile.sdk.util;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Date;

import org.json.JSONException;
import org.json.JSONObject;

import android.os.AsyncTask;

/**
 * Asynschronously fetches a remote json file with configuration data for the
 * SDK. File is stored locally and only re-fetched upon app start if the remote
 * file is younger than the local.
 */
class JSONFetcher extends AsyncTask<Void, Void, JSONObject> {

	private JSONContent jsonContent;

	private boolean doFetch;

	private String remote;

	private String local;

	private File localDir;

	private long localAge;

	private JSONObject localJson;

	private String logExt;

	private int lastError;

	private final static String TAG = "JSONFetcher";

	private final static String ACCEPT_HEADER_NAME = "Accept";

	private final static String ACCEPT_HEADER_VALUE = "text/plain,text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";

	private final static String ACCEPT_CHARSET_HEADER_NAME = "Accept-Charset";

	private final static String ACCEPT_CHARSET_HEADER_VALUE = "utf-8;q=0.7,*;q=0.3";

	private final static String ENCODING_STR = "utf-8";

	private final static byte[] EMPTY_BUFFER = new byte[1024];

	/**
	 * Constructor
	 * 
	 * @param listener
	 *            Content to be filled with fetched json
	 * @param remote
	 *            Remote path
	 * @param local
	 *            Local filename
	 * @param localDir
	 *            Local Directory
	 */
	JSONFetcher(JSONContent listener, String remote, String local, File localDir) {
		this.lastError = -1;
		this.jsonContent = listener;
		this.logExt = jsonContent.getClass().getSimpleName();
		SdkLog.d(TAG, "Instance for " + logExt);
		this.remote = remote;
		this.local = local;
		this.localDir = localDir;
		this.localAge = checkLocal();
		this.doFetch = true;
	}

	/**
	 * Constructor
	 * 
	 * @param listener
	 *            Content to be filled with fetched json
	 * @param remote
	 *            Remote path
	 * @param local
	 *            Local filename
	 * @param localDir
	 *            Local Directory
	 * @param maxAge
	 *            Use this age instead of remote file age
	 */
	JSONFetcher(JSONContent listener, String remote, String local,
			File localDir, long maxAge) {
		this.lastError = -1;
		this.jsonContent = listener;
		this.logExt = jsonContent.getClass().getSimpleName();
		SdkLog.d(TAG, "Instance for " + logExt);
		this.remote = remote;
		this.local = local;
		this.localDir = localDir;
		this.localAge = checkLocal();
		this.doFetch = localAge <= 0 || localAge > maxAge;
		SdkLog.d(TAG, logExt + " refetch ? " + doFetch + ", [" + localAge + ">"
				+ maxAge + "]");
	}

	/**
	 * Add an optional query string to the json request url
	 * 
	 * @param query
	 *            additional params string, starting with a "?"
	 */
	void addQueryString(String query) {
		if (remote != null && query != null) {
			remote = remote.concat("?" + query);
		}
	}

	private long checkLocal() {
		File f = new File(this.localDir, this.local);
		long age = f.lastModified();
		if (f.exists()) {
			// scan local file
			BufferedInputStream in = null;
			StringBuilder rBuilder = null;
			try {
				rBuilder = new StringBuilder();
				in = new BufferedInputStream(new FileInputStream(f));
				byte[] buffer = new byte[1024];
				int l = 0;
				while ((l = in.read(buffer)) > 0) {
					rBuilder.append(new String(buffer, ENCODING_STR), 0, l);
					buffer = EMPTY_BUFFER;
				}
			} catch (FileNotFoundException e0) {
				SdkLog.w(TAG, logExt + " not found: " + this.local);
			} catch (IOException e1) {
				SdkLog.e(TAG, logExt + " could not be read.", e1);
			} finally {
				try {
					if (in != null) {
						in.close();
					}
				} catch (Exception e2) {
				}
			}
			try {
				SdkLog.d(TAG, logExt + " will be parsed...");
				SdkLog.d(TAG, logExt + " " + rBuilder.toString());
				// parse local file
				this.localJson = new JSONObject(rBuilder.toString());
			} catch (JSONException e3) {
				SdkLog.e(TAG, logExt + " could not be parsed.", e3);
			}
		}
		f = null;

		return age;
	}

	@Override
	protected JSONObject doInBackground(Void... params) {
		if (doFetch) {
			StringBuilder rBuilder = new StringBuilder();
			SdkLog.d(TAG, logExt + " will be fetched from " + this.remote);
			HttpURLConnection con = null;
			try {
				URL uUrl = new URL(this.remote);
				lastError = 0;
				con = (HttpURLConnection) uUrl.openConnection();
				con.setRequestProperty(ACCEPT_HEADER_NAME, ACCEPT_HEADER_VALUE);
				con.setRequestProperty(ACCEPT_CHARSET_HEADER_NAME,
						ACCEPT_CHARSET_HEADER_VALUE);
				con.setReadTimeout(2500);
				con.setConnectTimeout(750);
				SdkLog.d(TAG, logExt + " local age: " + new Date(this.localAge));
				con.setIfModifiedSince(this.localAge);
				BufferedInputStream in = new BufferedInputStream(
						con.getInputStream());
				if (con.getResponseCode() == 200) {
					byte[] buffer = new byte[1024];
					int l = 0;
					while ((l = in.read(buffer)) > 0) {
						rBuilder.append(new String(buffer, ENCODING_STR), 0, l);
						buffer = EMPTY_BUFFER;
					}
				} else if (con.getResponseCode() == 304) {
					SdkLog.i(TAG, logExt
							+ " (local) is up to date - ignoring remote file.");
				} else if (con.getResponseCode() != 200) {
					lastError = con.getResponseCode();
					localAge = System.currentTimeMillis();
					throw new Exception(logExt + " resulted in HTTP "
							+ con.getResponseCode());
				}
				in.close();
			} catch (Exception e) {
				SdkLog.e(TAG, logExt + " could not be fetched.", e);
			} finally {
				if (con != null) {
					con.disconnect();
					SdkLog.d(TAG,
							logExt + " request finished. [" + rBuilder.length()
									+ "]");
				}
			}

			try {
				if (rBuilder.length() > 0) {
					return new JSONObject(rBuilder.toString());
				}
			} catch (Exception e) {
				SdkLog.e(TAG, logExt + " could not be parsed.", e);
			}
		} else {
			SdkLog.d(TAG, logExt + " not refetched due to file age control.");
		}

		return null;
	}

	JSONObject getJson() {
		return localJson;
	}

	/**
	 * Returns the last value of http response code
	 * 
	 * @return 0 if http response was 200, value of response code otherwise
	 */
	public int getLastError() {
		return lastError;
	}

	@Override
	protected void onPostExecute(JSONObject response) {
		if (response != null) {
			if (response.length() > 1) {
				SdkLog.i(TAG, logExt + " received new json from remote server.");
			}
			if (localJson == null
					|| (localJson != null && response.length() > 1)) {
				localJson = response;
				storeLocal();
			}
		} else if (localJson == null) {
			SdkLog.e(
					TAG,
					logExt
							+ " json file missing! Please contact mobile.tech@ems.guj.de");
		} else {
			SdkLog.d(TAG, logExt + " remote json is not younger than local");
		}
		jsonContent.feed(this.localJson);
	}

	private void storeLocal() {
		// locally store current config
		File f = new File(this.localDir, this.local);
		FileOutputStream fo = null;
		try {
			fo = new FileOutputStream(f);
			fo.write(localJson.toString().getBytes());
			SdkLog.d(TAG, logExt + " stored locally: " + this.localJson);
		} catch (Exception e) {
			SdkLog.e(TAG, logExt + " could not be stored locally.", e);
		} finally {
			if (fo != null) {
				try {
					fo.close();
				} catch (Exception e1) {
				}
			}
		}
	}

}