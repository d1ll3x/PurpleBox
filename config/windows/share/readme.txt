--------------------------------------------------------
 Windows for Docker v3.01...
 For support visit https://github.com/dockur/windows
--------------------------------------------------------

Using this folder you can share files with the host machine.

To change the storage location, include the following bind mount in your compose file:

  volumes:
    - "/home/user/example:/storage/shared"

Or in your run command:

  -v "/home/user/example:/storage/shared"

Replace the example path /home/user/example with the desired storage folder.

