#!/bin/sh

MYUSER="mezzanine"
MYGID="10004"
MYUID="10004"
MYPROJECT="myproject"
MYPORT="8000"
MYWORKERS="2"
MYPGDB=""
MYPGUSER=""
MYPGPASSWD=""
MYPGHOST=""
MYPGPORT="5432"

ConfigureSsmtp () {
  # Customizing sstmp
  if [ -f /etc/ssmtp/ssmtp.conf ];then
    # Configure relay
    if [ -n "${DOCKRELAY}" ]; then
      /bin/sed -i "s|mailhub=mail|mailhub=${DOCKRELAY}|i" /etc/ssmtp/ssmtp.conf
    fi
    # Configure root
    if [ -n "${DOCKMAIL}" ]; then
      /bin/sed -i "s|root=postmaster|root=${DOCKMAIL}|i" /etc/ssmtp/ssmtp.conf
    fi
    # Configure domain
    if [ -n "${DOCKMAILDOMAIN}" ]; then
      /bin/sed -i "s|#rewriteDomain=.*|rewriteDomain=${DOCKMAILDOMAIN}|i" /etc/ssmtp/ssmtp.conf
    fi
  fi
}

ConfigureUser () {
  # Managing user
  if [ -n "${DOCKUID}" ]; then
    MYUID="${DOCKUID}"
  fi
  # Managing group
  if [ -n "${DOCKGID}" ]; then
    MYGID="${DOCKGID}"
  fi
  local OLDHOME
  local OLDGID
  local OLDUID
  /bin/grep -q "${MYUSER}" /etc/passwd
  if [ $? -eq 0 ]; then
    OLDUID=$(/usr/bin/id -u "${MYUSER}")
    OLDGID=$(/usr/bin/id -g "${MYUSER}")
    if [ "${DOCKUID}" != "${OLDUID}" ]; then
      OLDHOME=$(/bin/echo "~${MYUSER}")
      /usr/sbin/deluser "${MYUSER}"
      /usr/bin/logger "Deleted user ${MYUSER}"
    fi
    /bin/grep -q "${MYUSER}" /etc/group
    if [ $? -eq 0 ]; then
      local OLDGID=$(/usr/bin/id -g "${MYUSER}")
      if [ "${DOCKGID}" != "${OLDGID}" ]; then
        /usr/sbin/delgroup "${MYUSER}"
        /usr/bin/logger "Deleted group ${MYUSER}"
      fi
    fi
  fi
  /usr/sbin/addgroup -S -g "${MYGID}" "${MYUSER}"
  /usr/sbin/adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
  if [ -n "${OLDUID}" ] && [ "${DOCKUID}" != "${OLDUID}" ]; then
    /usr/bin/find / -user "${OLDUID}" -exec /bin/chown ${MYUSER} {} \;
  fi
  if [ -n "${OLDGID}" ] && [ "${DOCKGID}" != "${OLDGID}" ]; then
    /usr/bin/find / -group "${OLDGID}" -exec /bin/chgrp ${MYUSER} {} \;
  fi
}

ConfigurePostgres()
{
  if [ -n "${DOCKPGHOST}" ]; then
    MYPGHOST="${DOCKPGHOST}"
    if [ -n "${DOCKPGUSER}" ]; then
      MYPGUSER="${DOCKPGUSER}"
      if [ -n "${DOCKPGPASSWD}" ]; then
        MYPGPASSWD="${DOCKPGPASSWD}"
        if [ -n "${DOCKPGDB}" ]; then
          MYPGDB="${DOCKPGDB}"
          if [ -n "${DOCKPGPORT}" ]; then
            MYPGPORT="${DOCKPGPORT}"
          fi
          /bin/sed -i "s|\s*\"ENGINE\"\s*:\s*\"django.db.backends.sqlite3\",|\ \ \ \ \ \ \ \ \"ENGINE\":\ \"django.db.backends.postgresql_psycopg2\",|g" /project/"${MYPROJECT}"/"${MYPROJECT}"/local_settings.py
          /bin/sed -i "s|\s*\"HOST\"\s*:\s*\"\",|\ \ \ \ \ \ \ \ \"HOST\":\ \"${MYPGHOST}\",|g" /project/"${MYPROJECT}"/"${MYPROJECT}"/local_settings.py
          /bin/sed -i "s|\s*\"PORT\"\s*:\s*\"\",|\ \ \ \ \ \ \ \ \"PORT\":\ \"${MYPGPORT}\",|g" /project/"${MYPROJECT}"/"${MYPROJECT}"/local_settings.py
          /bin/sed -i "s|\s*\"NAME\"\s*:\s*\"dev.db\",|\ \ \ \ \ \ \ \ \"NAME\":\ \"${MYPGDB}\",|g" /project/"${MYPROJECT}"/"${MYPROJECT}"/local_settings.py
          /bin/sed -i "s|\s*\"USER\"\s*:\s*\"\",|\ \ \ \ \ \ \ \ \"USER\":\ \"${MYPGUSER}\",|g" /project/"${MYPROJECT}"/"${MYPROJECT}"/local_settings.py
          /bin/sed -i "s|\s*\"PASSWORD\"\s*:\s*\"\",|\ \ \ \ \ \ \ \ \"PASSWORD\":\ \"${MYPGPASSWD}\",|g" /project/"${MYPROJECT}"/"${MYPROJECT}"/local_settings.py
        else
          /bin/echo "ERROR: postgresql database's name is missing, please define DOCKPGDB environment variable."
        fi  
      else
        /bin/echo "ERROR: postgresql user's password is missing, please define DOCKPGPASSWD environment variable. Note that empty password are not supported."
      fi
    else
      /bin/echo "ERROR: postgresql user is missing, please define DOCKPGUSER environment variable."
    fi
  else
    /bin/echo "INFO: No postgresql credentials defined, using, sqlite database."
  fi
}

ConfigureUser
ConfigureSsmtp

if [ "$1" = 'mezzanine' ]; then
  if [ -n "${DOCKMEZPRT}" ]; then
    MYPROJECT="${DOCKMEZPRT}"
  fi
  if [ -n "${DOCKUNIWRK}" ]; then
    MYWORKERS="${DOCKUNIWRK}"
  fi
  if [ -d "/project/${MYPROJECT}" ]; then
    cd "/project/${MYPROJECT}"
  else
    cd /project/
    /sbin/su-exec "${MYUSER}" mezzanine-project "${MYPROJECT}"
    cd "/project/${MYPROJECT}"
    ConfigurePostgres
    /sbin/su-exec "${MYUSER}" /usr/bin/python3 manage.py createdb --noinput
    /sbin/su-exec "${MYUSER}" /usr/bin/python3 manage.py collectstatic --noinput
  fi
   exec /sbin/su-exec "${MYUSER}" gunicorn -b 0.0.0.0:"${MYPORT}" -w "${MYWORKERS}" "${MYPROJECT}".wsgi
fi

exec "$@"
