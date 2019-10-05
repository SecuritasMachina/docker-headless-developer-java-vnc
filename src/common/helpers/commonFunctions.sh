function fail {
  echo $1 >&2
  exit 1
}

function retry {
  set +e
  local n=1
  local max=300
  local delay=5
  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Waiting $delay seconds, attempt $n/$max: $@"
        sleep $delay;
      else
      	set -e
        fail "The command has failed after $n attempts: $@"
      fi
    }
  done
}