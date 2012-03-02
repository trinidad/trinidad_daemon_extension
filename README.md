# Trinidad Daemon Extension

Extension to run Trinidad server as a daemon.

## Installation

    jruby -S gem install trinidad_daemon_extension

## Usage

This extension can be enabled from the Trinidad's configuration file or from the 
command line. It uses a temporal directory to write the pid file but its path 
can be overridden.

### Configuration file

Configure the daemon in the "extensions" section of the *trinidad.yml* file :

    ---
      extensions:
        daemon:
          # optional by default the pid is written into a temporal directory :
          pid_file: ./trinidad.pid

The extension also allows tuning JVM arguments to run the daemon with. 
They just need to be added into the *jvm_args* configuration section:

    ---
      extensions:
        daemon:
          jvm_args: '-XX:MaxPermSize=512m'

**NOTE:** Be aware that *jvm_args* are bare `java` options and not ones 
accepted by the `jruby` command !

### Command line

To enable the extension from the command line you have to load the extension 
first and then use it's `--daemonize [PID_FILE]` option e.g. :

    $ jruby -S trinidad --load daemon --daemonize ./trinidad.pid


You can find further information on how to write your own extension in the wiki: 
http://wiki.github.com/calavera/trinidad/extensions

## Development

Copy the hooks into *git-hooks* directory to *.git/hooks* to make sure the jar 
file is updated when the java code is modified.

You will need to have a JDK installed due to ant invoking `javac` and `jar`.

## Copyright

Copyright (c) 2010-2012 David Calavera. See LICENSE for details.
