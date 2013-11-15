package de.guj.ems.mobile.sdk.util;

import android.graphics.Bitmap;

public class ImageCache extends LRUCache<String, Bitmap> {
	 
	  public ImageCache( int maxSize ) {
	    super( maxSize );
	  }
	 
	  @Override
	  protected int sizeOf( String key, Bitmap value ) {
	    return value.getByteCount();
	  }
	 
	  @Override
	  protected void entryRemoved( boolean evicted, String key, Bitmap oldValue, Bitmap newValue ) {
	    oldValue.recycle();
	  }
	 
	}
