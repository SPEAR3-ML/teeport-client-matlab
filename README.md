Platform plugin for matlab
===============

This plugin uses MatlabWebSocket, which is a simple library consisting of a websocket server and client for MATLAB  built on [Java-WebSocket](https://github.com/TooTallNate/Java-WebSocket), a java implementation of the websocket protocol. Encryption is supported with self-signed certificates made with the java keytool.

Installation
------------

*IMPORTANT*: you must make sure to install the java library to the static class path by following the instructions below. MatlabWebSocket will not work otherwise!

The required java library is a `jar` file located in the `MatlabWebSocket/jar/` folder. It must be placed on the static java class path in MATLAB. For example, if the location of the jar file is `C:\platform-plugin-matlab\MatlabWebSocket\jar\matlab-websocket-*.*.jar`, then open the static class path file with the following command:
```matlab
edit(fullfile(prefdir,'javaclasspath.txt'))
```
and add the line `C:\platform-plugin-matlab\MatlabWebSocket\jar\matlab-websocket-*.*.jar` to it. Make sure that there are no other lines with a `matlab-websocket-*` entry.

Make sure to replace the stars `matlab-websocket-*.*.jar` with the correct version number that you downloaded.

After having done this, restart MATLAB and check that the line was read by MATLAB properly by running the `javaclasspath` command. The line should appear at the bottom of the list, before the `DYNAMIC JAVA PATH` entries. Note that seeing the entry here does not mean that MATLAB necessarily found the jar file properly. You must make sure that the actual `jar` file is indeed at this location.

You must now add the `platform-plugin-matlab` folder to the MATLAB path.

See the [MATLAB  Documentation](http://www.mathworks.com/help/matlab/matlab_external/static-path.html) for more information on the static java class path.

Usage
------------

**WIP**
