package de.guj.ems.mobile.sdk.controllers.adserver;

public class MOceanAdResponse extends AdResponse {

	private static final long serialVersionUID = 3072217505730377174L;

	public MOceanAdResponse(String response) {
		super(response);
		setIsRich(false);
		setEmpty(response == null || response.length() < 1);
		if (!isEmpty()) {
			setParser(new MOceanXmlParser(response));
		}
	}

}
