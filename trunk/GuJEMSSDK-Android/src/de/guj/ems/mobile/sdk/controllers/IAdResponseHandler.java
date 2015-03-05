package de.guj.ems.mobile.sdk.controllers;

import java.io.Serializable;

import de.guj.ems.mobile.sdk.controllers.adserver.IAdResponse;

/**
 * Interface for ad response processing. In most cases the listener
 * processResponse will be called with an object holding the (possibly empty)
 * response.
 * 
 * If an error occured, it is passed to processError
 * 
 * @author stein16
 * 
 */
public interface IAdResponseHandler extends Serializable {

	public abstract void processError(String msg);

	public abstract void processError(String msg, Throwable t);

	public abstract void processResponse(IAdResponse response);
}
