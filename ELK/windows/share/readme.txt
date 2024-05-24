--------------------------------------------------------
 Windows for Docker v3.05...
 For support visit https://github.com/dockur/windows
--------------------------------------------------------

Using this folder you can share files with the host machine.

To change its location, include the following bind mount in your compose file:

  volumes:
    - "/home/user/example:/shared"

Or in your run command:

  -v "/home/user/example:/shared"

Replace the example path /home/user/example with the desired shared folder.

