export PATH=${PATH}:/pub/bin
export SHAD_HOME="${HOME}/shad"

if [ "$HOSTNAME" = "shad" ]; then
  export SHAD_HOME="$HOME"
else
  # check whether we are mounted
  if ! $(grep ${SHAD_HOME} /proc/mounts >/dev/null 2>&1) ; then
    export SHAD_HOME=""
  fi
fi

