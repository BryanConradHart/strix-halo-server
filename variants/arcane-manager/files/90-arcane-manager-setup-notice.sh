if [ -t 0 ] && [ -t 1 ] && [ ! -e /etc/arcane/manager.env ]; then
  printf '\nArcane Manager setup is not complete.\n'
  printf 'Run setup now? [y/N] '
  if IFS= read -r answer &&
    case "$answer" in y|Y|yes|YES) true ;; *) false ;; esac; then
    if ! sudo /usr/libexec/arcane-manager-enroll.sh; then
      printf 'Arcane Manager setup did not complete. Rerun it with: sudo /usr/libexec/arcane-manager-enroll.sh\n' >&2
    fi
  else
    printf 'Setup deferred. It will be offered again at your next login. To run it now: sudo /usr/libexec/arcane-manager-enroll.sh\n'
  fi
fi
