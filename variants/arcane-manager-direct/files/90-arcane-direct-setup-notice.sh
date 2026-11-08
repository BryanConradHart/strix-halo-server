if [ ! -e /etc/arcane/agent.env ] && [ -t 0 ] && [ -t 1 ]; then
  printf '\nArcane Direct Agent enrollment is not complete.\n'
  printf 'Enroll the Direct Agent now? [Y/n] '
  if IFS= read -r answer &&
    case "$answer" in ''|y|Y|yes|YES) true ;; *) false ;; esac; then
    if ! sudo /usr/libexec/arcane-agent-enroll.sh; then
      printf 'Arcane Direct Agent enrollment did not complete. Rerun it with: sudo /usr/libexec/arcane-agent-enroll.sh\n' >&2
    fi
  else
    printf 'Enrollment deferred. It will be offered again at your next login. To run it now: sudo /usr/libexec/arcane-agent-enroll.sh\n'
  fi
fi
