if [ -t 0 ] && [ -t 1 ] && [ ! -e /etc/lemonade/server.env ]; then
  printf '\nLemonade Server setup is not complete.\n'
  printf 'Run setup now? [y/N] '
  if IFS= read -r answer &&
    case "$answer" in y|Y|yes|YES) true ;; *) false ;; esac; then
    if ! sudo /usr/libexec/lemonade-server-enroll.sh; then
      printf 'Lemonade setup did not complete. Rerun it with: sudo /usr/libexec/lemonade-server-enroll.sh\n' >&2
    fi
  else
    printf 'Setup deferred. It will be offered again at your next login. To run it now: sudo /usr/libexec/lemonade-server-enroll.sh\n'
  fi
fi
