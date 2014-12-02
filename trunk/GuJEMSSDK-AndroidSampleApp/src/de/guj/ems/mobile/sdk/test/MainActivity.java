/*
 * Copyright 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package de.guj.ems.mobile.sdk.test;

import org.ormma.view.Browser;

import android.app.Activity;
import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;
import de.guj.ems.mobile.sdk.controllers.InterstitialSwitchReceiver;
import de.guj.ems.mobile.sdk.util.SdkLog;
import de.guj.ems.mobile.sdk.util.SdkUtil;

public class MainActivity extends Activity {

	private final static String TAG = "GuJEMSSDK-SampleApp";

	private DrawerLayout mDrawerLayout;
	private ListView mDrawerList;
	private ActionBarDrawerToggle mDrawerToggle;

	private CharSequence mDrawerTitle;
	private CharSequence mTitle;
	private String[] mSampleTitles;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		SdkUtil.setContext(getApplicationContext());
		setContentView(R.layout.activity_main);

		mTitle = mDrawerTitle = getTitle();
		mSampleTitles = getResources().getStringArray(R.array.samples_array);
		mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
		mDrawerList = (ListView) findViewById(R.id.left_drawer);

		// set a custom shadow that overlays the main content when the drawer
		// opens
		if (mDrawerLayout != null) {
			mDrawerLayout.setDrawerShadow(R.drawable.drawer_shadow,
					GravityCompat.START);
		}
		// set up the drawer's list view with items and click listener
		mDrawerList.setAdapter(new ArrayAdapter<String>(this,
				R.layout.drawer_list_item, mSampleTitles));
		mDrawerList.setOnItemClickListener(new DrawerItemClickListener());

		// ActionBarDrawerToggle ties together the the proper interactions
		// between the sliding drawer and the action bar app icon
		if (mDrawerLayout != null) {
			mDrawerToggle = new ActionBarDrawerToggle(this, /* host Activity */
			mDrawerLayout, /* DrawerLayout object */
			R.drawable.ic_drawer, /* nav drawer image to replace 'Up' caret */
			R.string.drawer_open, /* "open drawer" description for accessibility */
			R.string.drawer_close /* "close drawer" description for accessibility */
			) {
				public void onDrawerClosed(View view) {
					super.onDrawerClosed(view);
					if (getActionBar() != null) {
						getActionBar().setTitle(mTitle);
					}
					invalidateOptionsMenu(); // creates call to
												// onPrepareOptionsMenu()
				}

				public void onDrawerOpened(View drawerView) {
					super.onDrawerOpened(drawerView);
					if (getActionBar() != null) {
						getActionBar().setTitle(mDrawerTitle);
					}
					invalidateOptionsMenu(); // creates call to
												// onPrepareOptionsMenu()
				}
			};
			mDrawerLayout.setDrawerListener(mDrawerToggle);
		}

		// enable ActionBar app icon to behave as action to toggle nav drawer
		if (getActionBar() != null) {
			getActionBar().setDisplayHomeAsUpEnabled(true);
			getActionBar().setHomeButtonEnabled(true);
		}
		if (savedInstanceState == null) {
			selectItem(0);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.extra, menu);
		return super.onCreateOptionsMenu(menu);
	}

	/* Called whenever we call invalidateOptionsMenu() */
	@Override
	public boolean onPrepareOptionsMenu(Menu menu) {
		// If the nav drawer is open, hide action items related to the content
		// view
		if (mDrawerLayout != null) {
			boolean drawerOpen = mDrawerLayout.isDrawerOpen(mDrawerList);
			menu.findItem(R.id.reload).setVisible(!drawerOpen);
		}
		return super.onPrepareOptionsMenu(menu);

	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle app icon touch
		if (mDrawerToggle != null && mDrawerToggle.onOptionsItemSelected(item)) {
			return true;
		}
		// Handle action buttons
		int menuId = item.getItemId();
		if (menuId == R.id.reload) {
			SdkLog.d(TAG, "Should reload all ads");
			return true;
		} else if (menuId == R.id.web) {
			Intent i = new Intent(MainActivity.this, Browser.class);
			i.putExtra(Browser.URL_EXTRA, "http://m.ems.guj.de/");
			i.putExtra(Browser.SHOW_BACK_EXTRA, true);
			i.putExtra(Browser.SHOW_FORWARD_EXTRA, true);
			i.putExtra(Browser.SHOW_REFRESH_EXTRA, true);
			startActivity(i);
			return true;
		} else if (menuId == R.id.showroom) {
			Intent i = new Intent(MainActivity.this, Browser.class);
			i.putExtra(Browser.URL_EXTRA, "http://showcase.emsmobile.de/");
			i.putExtra(Browser.SHOW_BACK_EXTRA, true);
			i.putExtra(Browser.SHOW_FORWARD_EXTRA, true);
			i.putExtra(Browser.SHOW_REFRESH_EXTRA, true);
			startActivity(i);
			return true;
		} else if (menuId == R.id.mail) {
			Intent intent = new Intent(Intent.ACTION_SEND);
			intent.setType("text/html");
			intent.putExtra(Intent.EXTRA_EMAIL, "mobile.tech@ems.guj.de");
			intent.putExtra(Intent.EXTRA_SUBJECT,
					"G+J EMS Sample App (Android)");
			intent.putExtra(Intent.EXTRA_TEXT, "");
			startActivity(Intent.createChooser(intent, "Kontakt"));
			return true;
		}
		return super.onOptionsItemSelected(item);
	}

	/* The click listener for ListView in the navigation drawer */
	private class DrawerItemClickListener implements
			ListView.OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position,
				long id) {
			selectItem(position);
		}
	}

	private void selectItem(int position) {
		// update the main content by replacing fragments
		if ("Retina".equals(mSampleTitles[position])) {
			Fragment fragment = new RetinaBannerTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("Web ListView".equals(mSampleTitles[position])) {
			Fragment fragment = new ListViewTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("Native ListView".equals(mSampleTitles[position])) {
			Fragment fragment = new NativeListViewTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("Web RelativeLayout".equals(mSampleTitles[position])) {
			Fragment fragment = new RelativeLayoutTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("Native RelativeLayout".equals(mSampleTitles[position])) {
			Fragment fragment = new NativeRelativeLayoutTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("TableLayout".equals(mSampleTitles[position])) {
			Fragment fragment = new TableLayoutTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("Interstitial".equals(mSampleTitles[position])) {
			// get the interstitial receiver's intent
			Intent i = new Intent(MainActivity.this,
					InterstitialSwitchReceiver.class);
			// configure it, this interstitial has no target,
			// i.e. it returns to the previous activity when finishing
			i.putExtra("ems_zoneId", "15310");
			i.putExtra("ems_uid", Boolean.valueOf(true));
			i.putExtra("ems_geo", Boolean.valueOf(true));
			sendBroadcast(i);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
			setTitle(mSampleTitles[position]);
		}
		if ("VideoInterstitial".equals(mSampleTitles[position])) {
			double rand = Math.random();
			Log.i(TAG, rand >= 0.5 ? "Wrapped Video Interstitial"
					: "Video Interstitial");
			// get the interstitial receiver's intent
			Intent i = new Intent(MainActivity.this,
					InterstitialSwitchReceiver.class);
			// configure it, this interstitial has no target,
			// i.e. it returns to the previous activity when finishing
			i.putExtra("ems_zoneId", rand >= 0.5 ? "9002" : "9001");
			i.putExtra("ems_uid", Boolean.valueOf(true));
			i.putExtra("ems_geo", Boolean.valueOf(true));
			// i.putExtra("unmuted", Boolean.valueOf(true));

			sendBroadcast(i);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
			setTitle(mSampleTitles[position]);
		}
		if ("Targeting".equals(mSampleTitles[position])) {
			Fragment fragment = new TargetingTest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("ORMMA".equals(mSampleTitles[position])) {
			Fragment fragment = new ORMMATest();
			FragmentManager fragmentManager = getFragmentManager();
			fragmentManager.beginTransaction()
					.replace(R.id.content_frame, fragment).commit();
			// update selected item and title, then close the drawer
			mDrawerList.setItemChecked(position, true);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
		if ("PreRoll".equals(mSampleTitles[position])) {
			Log.i(TAG, "G+J EMS PreRolls");
			double rand = Math.random();
			Intent target = new Intent(MainActivity.this, VideoPlayer.class);
			Log.i(TAG, rand >= 0.5 ? "Wrapped Video Interstitial"
					: "Video Interstitial");
			Intent i = new Intent(MainActivity.this,
					InterstitialSwitchReceiver.class);
			i.putExtra("ems_zoneId", rand >= 0.5 ? "9002" : "9001");
			i.putExtra("ems_uid", Boolean.valueOf(true));
			i.putExtra("ems_geo", Boolean.valueOf(true));
			i.putExtra("unmuted", Boolean.valueOf(true));
			i.putExtra("target", target);
			sendBroadcast(i);
			setTitle(mSampleTitles[position]);
			if (mDrawerLayout != null) {
				mDrawerLayout.closeDrawer(mDrawerList);
			}
			;
		}
	}

	@Override
	public void setTitle(CharSequence title) {
		mTitle = title;
		if (getActionBar() != null) {
			getActionBar().setTitle(mTitle);
		}
	}

	/**
	 * When using the ActionBarDrawerToggle, you must call it during
	 * onPostCreate() and onConfigurationChanged()...
	 */

	@Override
	protected void onPostCreate(Bundle savedInstanceState) {
		super.onPostCreate(savedInstanceState);
		// Sync the toggle state after onRestoreInstanceState has occurred.
		if (mDrawerToggle != null) {
			mDrawerToggle.syncState();
		}
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		// Pass any configuration change to the drawer toggls
		if (mDrawerToggle != null) {
			mDrawerToggle.onConfigurationChanged(newConfig);
		}
	}

	public void onInterstitialAdError(String msg) {
		System.out.println(msg);
	}

	public void onInterstitialAdError(String msg, Throwable t) {
		System.out.println(t.toString());
	}

	public void onAdEmpty() {
		Toast.makeText(this, "Ad is empty", Toast.LENGTH_SHORT).show();
	}

	public void onAdError(String msg) {
		Toast.makeText(this, "Ad error: " + msg, Toast.LENGTH_SHORT).show();
	}

	public void onAdError(String msg, Throwable t) {
		Toast.makeText(this, "Ad error: " + msg + " (" + t.getCause() + ")",
				Toast.LENGTH_SHORT).show();
	}

	public void onAdSuccess() {
		Toast.makeText(this, "Ad displayed.", Toast.LENGTH_SHORT).show();
	}

}