# zaw source for processes

function zaw-src-process () {
    local ps_list title ps pid_list
    if [ $(uname) = "Darwin" ] ; then       # for Macintosh
        ps_list="$(ps ax -o pid,%cpu,%mem,rss,command | (read -r; printf "%s\n" "$REPLY"; sort -k 5) | awk '$5 !~ /^\[/ {print $0}')"              # filter out kernel processes
    else
        ps_list="$(ps ax -o pid,%cpu,%mem,rss,command --sort command | awk '$5 !~ /^\[/ {print $0}')" # filter out kernel processes
    fi
    title="${${(f)ps_list}[1]}"
    ps="$(echo $ps_list | sed '1d')"
    pid_list="$(echo $ps | awk '{print $1}')"
    : ${(A)candidates::=${(f)pid_list}}
    : ${(A)cand_descriptions::=${(f)ps}}
    actions=(zaw-callback-append-to-buffer zaw-src-process-kill)
    act_descriptions=("insert" "kill")
    options=(-t "$title")
}

function zaw-src-process-kill () {
    local user="$(ps -ho user $1)"
    if [[ -z $user ]]; then
        echo "process with PID=$1 is not found"
        return 1
    fi
    if [[ $user = $USER ]]; then
        BUFFER="kill $1"
    else
        BUFFER="sudo kill $1"
    fi
    zle accept-line
}

zaw-register-src -n process zaw-src-process
