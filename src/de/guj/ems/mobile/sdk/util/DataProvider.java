package de.guj.ems.mobile.sdk.util;

import java.util.Date;
import java.util.Iterator;
import java.util.Set;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.database.AbstractCursor;
import android.database.Cursor;
import android.net.Uri;

public class DataProvider extends ContentProvider {

	public static final String PROVIDER_NAME = "de.guj.ems.mobile.data";

	public static final Uri CONTENT_URI = Uri.parse("content://"
			+ PROVIDER_NAME + "/info");

	SharedPreferences preferences;

	public DataProvider() {
	}

	@Override
	public boolean onCreate() {
		return true;
	}

	@Override
	public Cursor query(Uri uri, String[] projection, String selection,
			String[] selectionArgs, String sortOrder) {
		checkLoaded();
		Cursor c = null;
		c = new SimpleCursor(projection[0], preferences.getString(projection[0], ""));
		c.setNotificationUri(getContext().getContentResolver(), uri);
		return c;
	}

	@Override
	public String getType(Uri uri) {
		return "vnd.android.cursor.dir/de.guj.ems.mobile.info ";
	}

	@Override
	public Uri insert(Uri uri, ContentValues values) {
		checkLoaded();
		Set<String> keys = values.keySet();
		Iterator<String> iKeys = keys.iterator();
		Editor editor = preferences.edit();
		while (iKeys.hasNext()) {
			String key = iKeys.next();
			editor.putString(key, (String) values.get(key));
		}
		editor.commit();
		Uri _uri = ContentUris.withAppendedId(CONTENT_URI, preferences.getAll()
				.size());
		getContext().getContentResolver().notifyChange(_uri, null);
		return _uri;
	}

	@Override
	public int delete(Uri uri, String selection, String[] selectionArgs) {
		checkLoaded();
		if (preferences.contains(selection)) {
			Editor editor = preferences.edit();
			editor.remove(selection);
			editor.commit();
		}
		getContext().getContentResolver().notifyChange(uri, null);
		return preferences.getAll().size();
	}

	@Override
	public int update(Uri uri, ContentValues values, String selection,
			String[] selectionArgs) {
		checkLoaded();
		if (preferences.contains(selection)) {
			Editor editor = preferences.edit();
			editor.remove(selection);
			editor.commit();
			editor.putString(selection, values.getAsString(values.keySet().iterator().next()));
		}
		getContext().getContentResolver().notifyChange(uri, null);
		return preferences.getAll().size();
	}
	
	private void checkLoaded() {
		if (preferences == null) {
			preferences = SdkUtil.getContext().getSharedPreferences("GuJEMS", 0);
		}
	}
	
	private class SimpleCursor extends AbstractCursor {

		String name;
		
		String value;
		
		Date expires;
		
		final private String [] columnNames = {"name", "value", "expires"};
		
		public SimpleCursor(String name, String value, Date expires) {
			super();
			this.name = name;
			this.value = value;
			this.expires = expires;
		}
		
		@Override
		public int getCount() {
			return 3;
		}

		@Override
		public String[] getColumnNames() {
			return columnNames;
		}

		@Override
		public String getString(int column) {
			if (column > 2) {
				throw new ArrayIndexOutOfBoundsException();
			}
			return column == 0 ? name : (column == 1) ? value : expires.toString();
		}

		@Override
		public short getShort(int column) {
			return 0;
		}

		@Override
		public int getInt(int column) {
			return 0;
		}

		@Override
		public long getLong(int column) {
			return 0;
		}

		@Override
		public float getFloat(int column) {
			return 0;
		}

		@Override
		public double getDouble(int column) {
			return 0;
		}

		@Override
		public boolean isNull(int column) {
			return false;
		}
		
	}

}
