package de.guj.ems.mobile.sdk.controllers.adserver;


public abstract class AdResponse implements IAdResponse {

	private String response;
	
	private boolean isRich;
	
	private boolean isTest;
	
	private boolean isEmpty;
	
	private AdResponseParser parser;
	
	public AdResponse(String response) {
		this.response = response;
	}

	@Override
	public String getResponse() {
		return response;
	}

	@Override
	public boolean isImageAd() {
		return !isRich && !isEmpty;
	}

	@Override
	public boolean isRichAd() {
		return isRich && !isEmpty;
	}

	@Override
	public boolean isEmpty() {
		return isEmpty && !isRich;
	}

	@Override
	public boolean isTest() {
		return isTest;
	}
	
	@Override
	public AdResponseParser getParser() {
		return parser;
	}
	
	protected void setIsRich(boolean rich) {
		this.isRich = rich;
	}
	
	protected void setParser(AdResponseParser parser) {
		this.parser = parser;
	}
	
	protected void setEmpty(boolean empty) {
		isEmpty = empty;
	}
}
