package org.jruby.trinidad;

import javax.servlet.ServletException;

import org.apache.catalina.Context;
import org.apache.catalina.Server;
import org.apache.catalina.Service;
import org.apache.catalina.startup.Tomcat;
import com.sun.akuma.Daemon;

/**
 * Decorator to daemonize the process
 */
class TrinidadDaemon {

    private final Tomcat tomcat;
    private String pidFile = System.getenv().get("TMPDIR") + "/trinidad.pid";

    public TrinidadDaemon(Tomcat tomcat) {
        this.tomcat = tomcat;
    }

    public TrinidadDaemon(Tomcat tomcat, String pidFile) {
        this(tomcat);
        if (pidFile != null) {
            this.pidFile = pidFile;
        }
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
        try {
            Daemon daemon = new Daemon();
            if(daemon.isDaemonized()) {
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
}
