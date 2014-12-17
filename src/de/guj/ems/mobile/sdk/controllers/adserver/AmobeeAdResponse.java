package de.guj.ems.mobile.sdk.controllers.adserver;

public class AmobeeAdResponse extends AdResponse {

	private static final long serialVersionUID = -4429297832056469915L;

	public AmobeeAdResponse(String response, boolean richMedia) {
		super(response);
		setIsRich(richMedia);
		setEmpty(response == null || response.length() < 1);
		if (!isEmpty() && !richMedia) {
			setParser(new AmobeeHtmlParser(response));
		}
		// TODO check for retargeting ID
	}

}
