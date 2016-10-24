# docker-alp-mezzanine
Install mezzanine CMS into an Alpine Linux container. This container allows to connect to postgresql databases and run mezzanine under guincorn.

![mezzanine](http://mezzanine.jupo.org/static/img/mezzanine-logo.png)

## Description

Mezzanine is a powerful, consistent, and flexible content management platform. Built using the Django framework, Mezzanine provides a simple yet highly extensible architecture that encourages diving in and hacking on the code. 
This container allows to connect to postgresql databases and run mezzanine under guincorn.

http://mezzanine.jupo.org/

## Usage
    docker create --name=mezzanine \
      -v /etc/localtime:/etc/localtime:ro \
      -v <path to projects folder>:/project
      -e DOCKUID=<UID default:10004> \
      -e DOCKGID=<GID default:10004> \
      -e DOCKMAIL=<mail address> \
      -e DOCKRELAY=<smtp relay> \
      -e DOCKMAILDOMAIN=<originating mail domain> \
      -e DOCKUNIWRK=<number of gunicorn threads default:2> \
      -e DOCKMEZPRT=<mezzanine project name default:myproject> \
      -e DOCKPGHOST=<postgresql database hostname> \
      -e DOCKPGPORT=<postgresql database port default:5432> \
      -e DOCKPGDB=<postgresql database name> \
      -e DOCKPGUSER=<postgresql database user> \
      -e DOCKPGPASSWD=<postgresql database password> \
      -p 8000:8000 \
      digrouz/docker-alp-mezzanine
      
## Environment Variables

When you start the `mezzanine` image, you can adjust the configuration of the `mezzanine` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10004`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10004`.

### `DOCKRELAY`

This variable is not mandatory and specifies the smtp relay that will be used to send email. Do not specify any if mail notifications are not required.

### `DOCKMAIL`

This variable is not mandatory and specifies the mail that has to be used to send email. Do not specify any if mail notifications are not required.

### `DOCKMAILDOMAIN`

This variable is not mandatory and specifies the address where the mail appears to come from. Do not specify any if mail notifications are not required.

### `DOCKUNIWRK`

This variable is not mandatory and specifies the number of workers that will be started in gunicorn. It has default value `2`.

### `DOCKMEZPRT`

This variable is not mandatory and specifies the name to give to the mezzanine project. It has default value `myproject`.

### `DOCKPGHOST`

This variable is not mandatory and specifies the postgresql database host address. Do not specify any if postgresql support is not required, mezzanine will fall back to sqlite.

### `DOCKPGPORT`

This variable is not mandatory and specifies the postgresql database host port. Do not specify any if postgresql support is not required, mezzanine will fall back to sqlite.

### `DOCKPGDB`

This variable is not mandatory and specifies the postgresql database name. Do not specify any if postgresql support is not required, mezzanine will fall back to sqlite.

### `DOCKPGUSER`

This variable is not mandatory and specifies the postgresql database username. Do not specify any if postgresql support is not required, mezzanine will fall back to sqlite.

### `DOCKPGPASSWD`

This variable is not mandatory and specifies the postgresql database password. Do not specify any if postgresql support is not required, mezzanine will fall back to sqlite.

