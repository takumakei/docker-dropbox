docker-dropbox
======================================================================

The Dropbox Linux client runs on a container.


How to run
----------------------------------------------------------------------

```
docker run --name dropbox                  \
           --restart on-failure            \
           --detach                        \
           --memory 512m                   \
           --volume /data/dropbox:/dropbox \
           takumakei/dropbox
```

The first time you run this, you'll need to link the container to your dropbox account.
Look at the docker log with `docker logs dropbox`.
You should see messages like:

```
This computer isn't linked to any Dropbox account...
Please visit https://www.dropbox.com/cli_link_nonce?nonce=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
to link this device.
```

Simply copy that link into your browser and complete the linking process.
After you've done this the first time, subsequent runs wouldn't prompt you for this.


Acknowledgments
----------------------------------------------------------------------

Thanks github.com/cturra

https://github.com/cturra/docker-dropbox

This is awesome.


Copyright (c) 2018 takumakei
----------------------------------------------------------------------

see ./LICENSE
