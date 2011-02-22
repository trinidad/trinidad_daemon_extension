package org.jruby.trinidad;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;

import org.apache.catalina.Context;
import org.apache.catalina.Server;
import org.apache.catalina.Service;
import org.apache.catalina.startup.Tomcat;
import static com.sun.akuma.CLibrary.LIBC;
import com.sun.akuma.Daemon;
import com.sun.akuma.JavaVMArguments;

/**
 * Decorator to daemonize the process
 */
class TrinidadDaemon {

    private final Tomcat tomcat;
    private String pidFile = System.getenv().get("TMPDIR") + "trinidad.pid";
    private String[] jvmArgs;

    public TrinidadDaemon(Tomcat tomcat) {
        this.tomcat = tomcat;
    }

    public TrinidadDaemon(Tomcat tomcat, String pidFile) {
        this(tomcat);
        if (pidFile != null) {
            this.pidFile = new File(pidFile).getAbsolutePath();
        }
    }

    public TrinidadDaemon(Tomcat tomcat, String pidFile, String[] jvmArgs) {
      this(tomcat, pidFile);
      this.jvmArgs = jvmArgs;
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
                System.out.println("Starting Trinidad as a daemon");
                System.out.println("To stop it, kill -s SIGINT " + LIBC.getpid());

                daemon.init(pidFile);
            } else {
                daemon.daemonize(configureJVMArguments());
                System.exit(0);
            }
            tomcat.start();
            tomcat.getServer().await();
        } catch (Exception e) {
            System.err.println("Error daemonizing Trinidad: " + e.getMessage());
            System.exit(1);
        }
    }

    private JavaVMArguments configureJVMArguments() throws Exception {
        JavaVMArguments args = new JavaVMArguments();

        JavaVMArguments currentJVMArgs = JavaVMArguments.current();
        for (String arg : currentJVMArgs) {
            // I don't understand this hack but without it the daemon goes off, could be others
            if (!arg.endsWith("java")) {
                args.add(arg);
            }
        }

        for (String arg : jvmArgs) {
            args.add(arg);
        }

        return args;
    }
}
