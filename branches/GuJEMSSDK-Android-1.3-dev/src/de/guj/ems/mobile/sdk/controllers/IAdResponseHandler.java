package de.guj.ems.mobile.sdk.controllers;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdResponse;


public interface IAdResponseHandler {
	
	public void processResponse(IAdResponse response);
	
	public void processError(String msg);
	
	public void processError(String msg, Throwable t);
	
}
