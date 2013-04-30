package de.guj.ems.mobile.sdk.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.UUID;

/**
 * Generates a unique ID upon first start of the application. The ID is
 * random and will be used as a cookie replacement for frequency caps etc.
 *
 */
public class UUIDHelper {
	
    private static String sID = null;

    private static final String EMSUID = ".emsuid";

    /**
     * Get the unique user id for this app
     * @param context Android app context
     * @return string containing the id
     */
    public synchronized static String getUUID() {
        if (sID == null) {  
            File fuuid = new File(AppContext.getContext().getFilesDir(), EMSUID);
            try {
                if (!fuuid.exists())
                    writeUUID(fuuid);
                sID = readUUID(fuuid);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        return sID;
    }

    private static String readUUID(File fuuid) throws IOException {
        RandomAccessFile f = new RandomAccessFile(fuuid, "r");
        byte[] bytes = new byte[(int) f.length()];
        f.readFully(bytes);
        f.close();
        return new String(bytes);
    }

    private static void writeUUID(File fuuid) throws IOException {
        FileOutputStream out = new FileOutputStream(fuuid);
        String id = UUID.randomUUID().toString();
        out.write(id.getBytes());
        out.close();
    }
}
