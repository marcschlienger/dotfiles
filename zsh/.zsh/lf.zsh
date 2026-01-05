# ${HOME}/.zsh/lf.zsh

# Shell function to automatically change the current working directory to the
# last visited directory after lf quits. To undo the effect of this
# function, you can type "cd -" to return to the original directory.
lfcd () {
    local tmp_file="$(mktemp)"

    lf -last-dir-path="${tmp_file}" "$@"

    if [ -f "${tmp_file}" ]; then
        local dir=$(cat "${tmp_file}")
        \rm -f -- "${tmp_file}"

        if [ -d "${dir}" ] && [ "${dir}" != "$(pwd)" ]; then
            cd  -- "${dir}"/
        fi
    fi
}

alias lf='lfcd'
