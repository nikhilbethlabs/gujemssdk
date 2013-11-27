package de.guj.ems.mobile.sdk.controllers.adserver;


public interface IAdResponse {
	
	public String getResponse();
	
	public AdResponseParser getParser();
	
	public boolean isImageAd();
	
	public boolean isRichAd();
	
	public boolean isEmpty();
	
	public boolean isTest();

}
