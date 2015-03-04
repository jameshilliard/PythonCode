package com.demo;

import java.io.File;

import org.apache.log4j.Logger;
import org.apache.log4j.PropertyConfigurator;

public class Log {
	private static Logger logger;

    private static String filePath = "src/log4j.properties";

    private static boolean flag = false;

    private static synchronized void getPropertyFile() {
        logger = Logger.getLogger("TestProject");
        PropertyConfigurator.configure(new File(filePath).getAbsolutePath());
        flag = true;
    }

    private static void getFlag() {
        if (flag == false)
            Log.getPropertyFile();
    }

    public static void logInfo(String message) {
        Log.getFlag();
        logger.info(message);
    }

    public static void logError(String message) {
        Log.getFlag();
        logger.error(message);
    }

    public static void logWarn(String message) {
        Log.getFlag();
        logger.warn(message);
    }
}
