#!/bin/sh
# Smoke test run by mithro/apt-repo-action's install test, as root in a
# clean container of the suite, after the built package is installed.
set -eu

# Both console scripts import the package and answer with its version.
smfc --version
smfc-client --version

# What the package lays down: the configuration the service reads, its
# command-line options, the unit, the manual pages and the sample
# configurations (debian/smfc.install, debian/smfc.manpages).
test -f /etc/smfc/smfc.conf
test -f /etc/default/smfc
test -f /usr/lib/systemd/system/smfc.service
test -f /usr/share/man/man1/smfc.1.gz
test -f /usr/share/man/man1/smfc-client.1.gz
test -n "$(ls /usr/share/doc/smfc/examples/*.conf)"

# The unit runs `smfc $OPTIONS` with the options from /etc/default/smfc; the
# default options must parse (the config file need not exist for -h).
. /etc/default/smfc
echo "OPTIONS=$OPTIONS"
case "$OPTIONS" in
  *"-c /etc/smfc/smfc.conf"*) ;;
  *) echo "/etc/default/smfc does not point OPTIONS at /etc/smfc/smfc.conf" >&2; exit 1 ;;
esac

echo "install test passed"
