_zpcompinit-custom() {
    # https://gist.github.com/ctechols/ca1035271ad134841284
    # On slow systems, checking the cached .zcompdump file to see if it must be
    # regenerated adds a noticable delay to zsh startup.  This little hack restricts
    # it to once a day.  It should be pasted into your own completion file.
    #
    # The globbing is a little complicated here:
    # - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
    # - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
    # - '.' matches "regular files"
    # - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.

    # Perform compinit only once a day.

    # Compile the completion dump to increase startup speed, if dump is newer or doesn't exist,
    # in the background as this is doesn't affect the current session.

    setopt EXTENDEDGLOB LOCAL_OPTIONS
    autoload -Uz compinit
    autoload -Uz bashcompinit && bashcompinit
    zmodload -i zsh/complist

    local zcd=${ZINIT[ZCOMPDUMP_PATH]:-${ZDOTDIR:-$HOME}/.zcompdump}
    local zcdc="${zcd}.zwc"
    if [[ -f ${zcd}(#qN.m+1) ]]; then
        compinit -i -d "${zcd}"
        { rm -f "${zcdc}" && zcompile "${zcd}" } &!
    else
        compinit -C -d "${zcd}"
        { [[ ! -f "${zcdc}" || "${zcd}" -nt "${zcdc}" ]] && rm -f "${zcdc}" && zcompile "${zcd}" } &!
    fi
}

_zsh-auto-update() {
    # fork from @unixorn/autoupdate-zgen
    # Copyright 2014-2017 Joe Block <jpb@unixorn.net>
    #
    # Licensed under the Apache License, Version 2.0 (the "License");
    # you may not use this file except in compliance with the License.
    # You may obtain a copy of the License at
    #
    #     http://www.apache.org/licenses/LICENSE-2.0
    #
    # Unless required by applicable law or agreed to in writing, software
    # distributed under the License is distributed on an "AS IS" BASIS,
    # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    # See the License for the specific language governing permissions and
    # limitations under the License.

    _zsh-check-interval() {
        now=$(date +%s)
        if [ -f ~/"${1}" ]; then
            last_update=$(cat ~/"${1}")
        else
            last_update=0
        fi
        interval=$(expr ${now} - ${last_update})
        echo "${interval}"
    }

    _zsh-check-for-updates() {
        if [ -z "${ZSHR_PLUGIN_UPDATE_DAYS}" ]; then
            ZSHR_PLUGIN_UPDATE_DAYS=7
        fi

        if [ -z "${ZSHR_SYSTEM_UPDATE_DAYS}" ]; then
            ZSHR_SYSTEM_UPDATE_DAYS=7
        fi

        if [ -z "${ZSHR_SYSTEM_RECEIPT_F}" ]; then
            ZSHR_SYSTEM_RECEIPT_F='.zsh_system_lastupdate'
        fi

        if [ -z "${ZSHR_PLUGIN_RECEIPT_F}" ]; then
            ZSHR_PLUGIN_RECEIPT_F='.zsh_plugin_lastupdate'
        fi

        local day_seconds=$(expr 24 \* 60 \* 60)
        local system_seconds=$(expr "${day_seconds}" \* "${ZSHR_SYSTEM_UPDATE_DAYS}")
        local plugins_seconds=$(expr ${day_seconds} \* ${ZSHR_PLUGIN_UPDATE_DAYS})

        local last_plugin=$(_zsh-check-interval ${ZSHR_PLUGIN_RECEIPT_F})
        local last_system=$(_zsh-check-interval ${ZSHR_SYSTEM_RECEIPT_F})

        if [ ${last_plugin} -gt ${plugins_seconds} ]; then
            if [ ! -z "${ZSHR_AUTOUPDATE_VERBOSE}" ]; then
                echo "It has been $(expr ${last_plugin} / $day_seconds) days since your plugins were updated"
                echo "Updating plugins"
            fi
            unfunction _zinit-check-remote
            autoload -Uz _zinit-check-remote
            _zinit-check-remote

            zinit self-update
            zinit update
            date +%s >! ~/${ZSHR_PLUGIN_RECEIPT_F}
        fi

        if [ ${last_system} -gt ${system_seconds} ]; then
            if [ ! -z "${ZSHR_AUTOUPDATE_VERBOSE}" ]; then
                echo "It has been $(expr ${last_plugin} / ${day_seconds}) days since your ZSHR was updated"
                echo "Updating ZSHR..."
            fi
            git -C $ZSHR pull
            zsh-compile
            unfunction _zinit-check-remote
            autoload -Uz _zinit-check-remote
            _zinit-check-remote
            date +%s >! ~/${ZSHR_SYSTEM_RECEIPT_F}
        fi
    }

    zmodload zsh/system
    lockfile=${ZSHR}/.zsh_autoupdate_lock
    touch $lockfile
    if ! which zsystem &> /dev/null || zsystem flock -t 1 $lockfile; then
        _zsh-check-for-updates
        command rm -f $lockfile
    fi
}

load-file() {
  local file_path="$1"
  local alter_path="$2"

  if [[ -z "$alter_path" ]] || ! [[ -f "$alter_path" ]]; then
    if [[ -f "$file_path" ]]; then
      source "$file_path"
    fi
  else
    source "$alter_path"
  fi
}
