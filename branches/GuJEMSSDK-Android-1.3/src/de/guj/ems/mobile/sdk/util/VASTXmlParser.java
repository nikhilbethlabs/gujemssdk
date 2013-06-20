package de.guj.ems.mobile.sdk.util;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;

import android.util.Xml;

public class VASTXmlParser {

	private final static String TAG = "VASTXmlParser";

	private final static String VAST_START_TAG = "VAST";

	private final static String VAST_AD_TAG = "Ad";

	private final static String VAST_INLINE_TAG = "InLine";

	private final static String VAST_IMPRESSION_TAG = "Impression";

	private final static String VAST_CREATIVES_TAG = "Creatives";

	private final static String VAST_CREATIVE_TAG = "Creative";

	private final static String VAST_LINEAR_TAG = "Linear";

	private final static String VAST_DURATION_TAG = "Duration";

	private final static String VAST_TRACKINGEVENTS_TAG = "TrackingEvents";

	private final static String VAST_TRACKING_TAG = "Tracking";

	private final static String VAST_MEDIAFILES_TAG = "MediaFiles";

	private final static String VAST_MEDIAFILE_TAG = "MediaFile";

	private String impressionTrackerUrl;

	private String duration;

	private String mediaFileUrl;

	private List<Tracking> trackings;

	public class Tracking {

		public final static int EVENT_FINAL_RETURN = 0;

		public final static int EVENT_IMPRESSION = 1;

		public final static int EVENT_START = 2;

		public final static int EVENT_FIRSTQ = 3;

		public final static int EVENT_MID = 4;

		public final static int EVENT_THIRDQ = 5;

		public final static int EVENT_COMPLETE = 6;

		public final static int EVENT_MUTE = 7;

		public final static int EVENT_UNMUTE = 8;

		public final static int EVENT_PAUSE = 9;

		public final static int EVENT_RESUME = 10;

		public final String[] EVENT_MAPPING = new String[] { "finalReturn",
				"impression", "start", "firstQuartile", "midpoint",
				"thirdQuartile", "complete", "mute", "unmute", "pause",
				"resume" };

		private int event;

		private String url;

		public Tracking(String e, String url) {
			this.event = findEvent(e);
			this.url = url;
			SdkLog.i(TAG, "VAST tracking url [" + e + ", " + this.event + "]: "
					+ this.url);
		}

		private int findEvent(String event) {
			for (int i = 0; i < EVENT_MAPPING.length; i++) {
				if (EVENT_MAPPING[i].equals(event)) {
					return i;
				}
			}
			return -1;
		}

		public int getEvent() {
			return this.event;
		}

		public String getUrl() {
			return this.url;
		}

	}

	public VASTXmlParser(String data) {
		this.trackings = new ArrayList<Tracking>();

		try {
			readVAST(data);
		} catch (Exception e) {
			SdkLog.e(TAG, "Error parsing VAST XML", e);
		}
	}

	private void readVAST(String data) throws XmlPullParserException,
			IOException {

		XmlPullParser parser = Xml.newPullParser();
		parser.setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, false);
		parser.setInput(new StringReader(data));
		parser.nextTag();
		parser.require(XmlPullParser.START_TAG, null, VAST_START_TAG);
		while (parser.next() != XmlPullParser.END_TAG) {
			if (parser.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			if (parser.getName().equals(VAST_AD_TAG)) {
				readAd(parser);
			}
		}
	}

	private void readAd(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_AD_TAG);
		SdkLog.d(TAG, "Found Ad node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name.equals(VAST_INLINE_TAG)) {
				readInLine(p);
			}
		}
	}

	private void readMediaFiles(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_MEDIAFILES_TAG);
		SdkLog.d(TAG, "Found MediaFiles node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name != null && name.equals(VAST_MEDIAFILE_TAG)) {
				p.require(XmlPullParser.START_TAG, null, VAST_MEDIAFILE_TAG);
				this.mediaFileUrl = readText(p);
				p.require(XmlPullParser.END_TAG, null, VAST_MEDIAFILE_TAG);
				SdkLog.i(TAG, "VAST mediafile url: " + this.mediaFileUrl);
			} else {
				skip(p);
			}
		}
	}

	private void readTrackingEvents(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_TRACKINGEVENTS_TAG);
		SdkLog.d(TAG, "Found TrackingEvents node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name != null && name.equals(VAST_TRACKING_TAG)) {
				String ev = p.getAttributeValue(null, "event");
				p.require(XmlPullParser.START_TAG, null, VAST_TRACKING_TAG);
				this.trackings.add(new Tracking(ev, readText(p)));
				SdkLog.d(TAG, "Added VAST tracking \"" + ev + "\"");
				p.require(XmlPullParser.END_TAG, null, VAST_TRACKING_TAG);
			} else {
				skip(p);
			}
		}
	}

	private void readLinear(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_LINEAR_TAG);
		SdkLog.d(TAG, "Found Linear node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name != null && name.equals(VAST_DURATION_TAG)) {
				SdkLog.d(TAG, "Found Duration node in VAST xml.");
				p.require(XmlPullParser.START_TAG, null, VAST_DURATION_TAG);
				this.duration = readText(p);
				p.require(XmlPullParser.END_TAG, null, VAST_DURATION_TAG);

				SdkLog.i(TAG, "VAST duration: " + this.duration);
			} else if (name != null && name.equals(VAST_TRACKINGEVENTS_TAG)) {
				readTrackingEvents(p);
			} else if (name != null && name.equals(VAST_MEDIAFILES_TAG)) {
				readMediaFiles(p);
			} else {
				skip(p);
			}
		}
	}

	private void readCreative(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_CREATIVE_TAG);
		SdkLog.d(TAG, "Found Creative node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name != null && name.equals(VAST_LINEAR_TAG)) {
				readLinear(p);
			} else {
				skip(p);
			}
		}
	}

	private void readCreatives(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_CREATIVES_TAG);
		SdkLog.d(TAG, "Found Creatives node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name != null && name.equals(VAST_CREATIVE_TAG)) {
				readCreative(p);
			} else {
				skip(p);
			}
		}
	}

	private void readInLine(XmlPullParser p) throws IOException,
			XmlPullParserException {
		p.require(XmlPullParser.START_TAG, null, VAST_INLINE_TAG);
		SdkLog.d(TAG, "Found InLine node in VAST xml.");
		while (p.next() != XmlPullParser.END_TAG) {
			if (p.getEventType() != XmlPullParser.START_TAG) {
				continue;
			}
			String name = p.getName();
			if (name != null && name.equals(VAST_IMPRESSION_TAG)) {
				SdkLog.d(TAG, "Found Impression node in VAST xml.");
				p.require(XmlPullParser.START_TAG, null, VAST_IMPRESSION_TAG);
				this.impressionTrackerUrl = readText(p);
				p.require(XmlPullParser.END_TAG, null, VAST_IMPRESSION_TAG);

				SdkLog.i(TAG, "VAST impression tracker url: "
						+ this.impressionTrackerUrl);
			} else if (name != null && name.equals(VAST_CREATIVES_TAG)) {
				readCreatives(p);
			} else {
				skip(p);
			}
		}
	}

	private void skip(XmlPullParser p) throws XmlPullParserException,
			IOException {
		if (p.getEventType() != XmlPullParser.START_TAG) {
			throw new IllegalStateException();
		}
		int depth = 1;
		while (depth != 0) {
			switch (p.next()) {
			case XmlPullParser.END_TAG:
				depth--;
				break;
			case XmlPullParser.START_TAG:
				depth++;
				break;
			}
		}
	}

	private String readText(XmlPullParser parser) throws IOException,
			XmlPullParserException {
		String result = "";
		if (parser.next() == XmlPullParser.TEXT) {
			result = parser.getText();
			parser.nextTag();
		} else {
			SdkLog.w(TAG, "No text :: " + parser.getName());
		}
		return result.trim();
	}

	public String getImpressionTrackerUrl() {
		return impressionTrackerUrl;
	}

	public String getDuration() {
		return duration;
	}

	public String getMediaFileUrl() {
		return mediaFileUrl;
	}

	public List<Tracking> getTrackings() {
		return trackings;
	}
	
	public String getTrackingByType(int type) {
		Iterator<Tracking> i = this.trackings.iterator();
		while (i.hasNext()) {
			Tracking t = i.next();
			if (t.getEvent() == type) {
				return t.getUrl();
			}
		}
		return null;
	}

}
