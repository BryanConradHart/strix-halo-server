# Setup is offered when a required value is missing. Missing means absent from
# the setup env file and unresolvable from any Quadlet drop-in, so a value the
# user supplies through a drop-in never triggers the offer. The env file is
# root-only, so completeness is checked by the setup script itself. Without
# passwordless sudo, fall back to offering setup whenever the file is absent.
if [ -t 0 ] && [ -t 1 ]; then
  if sudo -n /usr/libexec/lemonade-server-enroll.sh --check 2>/dev/null; then
    incomplete=true
  elif [ ! -e /etc/lemonade/server.env ]; then
    incomplete=true
  else
    incomplete=false
  fi
else
  incomplete=false
fi

if $incomplete; then
  printf '\nLemonade Server setup is not complete.\n'
  printf 'Run setup now? [Y/n] '
  if IFS= read -r answer &&
    case "$answer" in ''|y|Y|yes|YES) true ;; *) false ;; esac; then
    if ! sudo /usr/libexec/lemonade-server-enroll.sh; then
      printf 'Lemonade setup did not complete. Rerun it with: sudo /usr/libexec/lemonade-server-enroll.sh\n' >&2
    fi
  else
    printf 'Setup deferred. It will be offered again at your next login. To run it now: sudo /usr/libexec/lemonade-server-enroll.sh\n'
  fi
fi
