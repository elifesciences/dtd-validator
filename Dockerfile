FROM basex/basexhttp:9.2.3
COPY --chown=basex webapp /srv/basex/webapp
COPY saxon9he.jar /usr/src/basex/basex-api/lib/saxon9he.jar
COPY --chown=basex .basex /srv/basex