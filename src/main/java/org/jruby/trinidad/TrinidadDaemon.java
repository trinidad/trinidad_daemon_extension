package org.jruby.trinidad;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.FileHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

import javax.servlet.ServletException;

import org.apache.catalina.Context;
import org.apache.catalina.Server;
import org.apache.catalina.Service;
import org.apache.catalina.startup.Tomcat;
import org.apache.juli.logging.LogFactory;
import static com.sun.akuma.CLibrary.LIBC;
import com.sun.akuma.Daemon;

/**
 * Decorator to daemonize the process
 */
class TrinidadDaemon {

    private final Tomcat tomcat;
    private String pidFile = System.getenv().get("TMPDIR") + "trinidad.pid";
    private Map<String, String> loggerOptions = new HashMap<String, String>();

    public TrinidadDaemon(Tomcat tomcat) {
        this.tomcat = tomcat;
    }

    public TrinidadDaemon(Tomcat tomcat, String pidFile) {
        this(tomcat);
        if (pidFile != null) {
            this.pidFile = new File(pidFile).getAbsolutePath();
        }
    }

    public TrinidadDaemon(Tomcat tomcat, String pidFile, Map<String, String> loggerOptions) {
      this(tomcat, pidFile);
      this.loggerOptions = loggerOptions;
    }

    public String getPidFile() {
        return pidFile;
    }

    public Context addWebapp(String contextPath, String baseDir) throws ServletException {
        return tomcat.addWebapp(contextPath, baseDir);
    }

    public Service getService() {
        return tomcat.getService();
    }

    public Server getServer() {
        return tomcat.getServer();
    }

    public Context addContext(String contextPath, String baseDir) {
        return tomcat.addContext(contextPath, baseDir);
    }

    public void stop() throws Exception {
        tomcat.stop();
    }

    public void start() {
        String log = configureLogger();

        try {
            Daemon daemon = new Daemon();
            if(daemon.isDaemonized()) {
                System.out.println("Starting Trinidad as a daemon, writing log into " + log);
                System.out.println("To stop it, kill -s SIGINT " + LIBC.getpid());

                daemon.init(pidFile);
            } else {
                daemon.daemonize();
                System.exit(0);
            }
            tomcat.start();
            tomcat.getServer().await();
        } catch (Exception e) {
            System.err.println("Error daemonizing Trinidad: " + e.getMessage());
            System.exit(1);
        }
    }

    private String configureLogger() {
      final String log = loggerOptions.get("file");
      final String level = loggerOptions.get("level");

      try {
          final File logFile = new File(log);
          final FileHandler handler = new FileHandler(log, true);
          final Logger logger = Logger.getLogger("");

          if(!logFile.exists()){
              logFile.getParentFile().mkdirs();
              logFile.createNewFile();
          }

          handler.setFormatter(new SimpleFormatter());
          logger.addHandler(handler);
      } catch (Exception e) {
          System.err.println("Error configuring the daemon's log: " + e.getMessage());
      }

      return log;
    }
}
