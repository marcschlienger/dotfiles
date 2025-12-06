# ${HOME}/.zsh/ranger.zsh

# Shell function to automatically change the current working directory to the 
# last visited directory after ranger quits. To undo the effect of this 
# function, you can type "cd -" to return to the original directory.
ranger_cd() {
    local temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"

    ranger --choosedir="${temp_file}" -- "${@:-${PWD}}"

    local chosen_dir=$(cat -- "${temp_file}")
    if [ -n "${chosen_dir}" ] && [ "${chosen_dir}" != "${PWD}" ]; then
        cd -- "${chosen_dir}"/
    fi

    \rm -f -- "${temp_file}"
}

bindkey -s '^n' 'ranger_cd\n'

# Only use my personal configuration 
export RANGER_LOAD_DEFAULT_RC=FALSE
