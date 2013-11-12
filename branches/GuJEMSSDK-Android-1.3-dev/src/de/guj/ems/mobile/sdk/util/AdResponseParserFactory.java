package de.guj.ems.mobile.sdk.util;

public class AdResponseParserFactory {
	
	public final static AdResponseParser getParser(String response) {
		if (response != null && response.indexOf("amobee") > 0) {
			return new AmobeeHtmlParser(response);
		}
		else if (response != null && response.indexOf("mocean") > 0) {
			return new OptimobileXmlParser(response);
		}
		
		return null;
	}

}
