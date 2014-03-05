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
public class JSONFetcher extends AsyncTask<Void, Void, JSONObject> {

	private JSONContent jsonContent;

	private boolean doFetch;

	private String remote;

	private String local;

	private File localDir;

	private long localAge;

	private JSONObject localJson;

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
	public JSONFetcher(JSONContent listener, String remote, String local,
			File localDir) {
		this.jsonContent = listener;
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
	public JSONFetcher(JSONContent listener, String remote, String local,
			File localDir, long maxAge) {
		this.jsonContent = listener;
		this.remote = remote;
		this.local = local;
		this.localDir = localDir;
		this.localAge = checkLocal();
		this.doFetch = localAge <= 0 || localAge > maxAge;
	}

	// TODO constructor with optional params for fetching request

	private void storeLocal() {
		// locally store current config
		File f = new File(this.localDir, this.local);
		FileOutputStream fo = null;
		try {
			fo = new FileOutputStream(f);
			fo.write(localJson.toString().getBytes());
			SdkLog.d(TAG, "Local json: " + this.localJson);
		} catch (Exception e) {
			SdkLog.e(TAG, "Error storing json locally", e);
		} finally {
			if (fo != null) {
				try {
					fo.close();
				} catch (Exception e1) {
				}
			}
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
				SdkLog.w(TAG, "File not found: " + this.local);
			} catch (IOException e1) {
				SdkLog.e(TAG, "Could not read json file.", e1);
			} finally {
				try {
					if (in != null) {
						in.close();
					}
				} catch (Exception e2) {
				}
			}
			try {
				SdkLog.d(TAG, "Parsing local json...");
				SdkLog.d(TAG, rBuilder.toString());
				// parse local file
				this.localJson = new JSONObject(rBuilder.toString());
			} catch (JSONException e3) {
				SdkLog.e(TAG, "Error parsing json", e3);
			}
		}
		f = null;

		return age;
	}

	@Override
	protected JSONObject doInBackground(Void... params) {
		if (doFetch) {
			StringBuilder rBuilder = new StringBuilder();
			SdkLog.d(TAG, "Trying to fetch " + this.remote);
			HttpURLConnection con = null;
			try {
				URL uUrl = new URL(this.remote);
				con = (HttpURLConnection) uUrl.openConnection();
				con.setRequestProperty(ACCEPT_HEADER_NAME, ACCEPT_HEADER_VALUE);
				con.setRequestProperty(ACCEPT_CHARSET_HEADER_NAME,
						ACCEPT_CHARSET_HEADER_VALUE);
				con.setReadTimeout(2500);
				con.setConnectTimeout(750);
				SdkLog.d(TAG, "Local last json change: "
						+ new Date(this.localAge));
				con.setIfModifiedSince(this.localAge);
				BufferedInputStream in = new BufferedInputStream(
						con.getInputStream());
				if (con.getResponseCode() == 200) {
					SdkLog.d(
							TAG,
							"Remote Last-Modified response: "
									+ con.getHeaderField("Last-Modified"));
					byte[] buffer = new byte[1024];
					int l = 0;
					while ((l = in.read(buffer)) > 0) {
						rBuilder.append(new String(buffer, ENCODING_STR), 0, l);
						buffer = EMPTY_BUFFER;
					}
				} else if (con.getResponseCode() == 304) {
					SdkLog.i(TAG,
							"Local json is up to date - ignoring remote file.");
				} else if (con.getResponseCode() != 200) {

					throw new Exception("JSNOFetcher remote returned HTTP "
							+ con.getResponseCode());
				}
				in.close();
			} catch (Exception e) {
				SdkLog.e(TAG, "Error fetching json.", e);
			} finally {
				if (con != null) {
					con.disconnect();
					SdkLog.d(TAG,
							"Json request finished. [" + rBuilder.length()
									+ "]");
				}
			}

			try {
				if (rBuilder.length() > 0) {
					return new JSONObject(rBuilder.toString());
				}
			} catch (Exception e) {
				SdkLog.e(TAG, "Error reading json", e);
			}
		} else {
			SdkLog.d(TAG, "Not fetching remote json due to file age control");
		}

		return null;
	}

	@Override
	protected void onPostExecute(JSONObject response) {
		if (response != null) {
			if (response.length() > 1) {
				SdkLog.i(TAG, "Received new json from remote server.");
			}
			if (localJson == null
					|| (localJson != null && response.length() > 1)) {
				localJson = response;
				storeLocal();
			}
		} else if (localJson == null) {
			SdkLog.e(TAG,
					"Missing json file! Please contact mobile.tech@ems.guj.de");
		} else {
			SdkLog.d(TAG, "Remote json is not younger than local");
		}
		jsonContent.feed(this.localJson);
	}

	JSONObject getJson() {
		return localJson;
	}

}
