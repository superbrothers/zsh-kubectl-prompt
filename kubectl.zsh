setopt prompt_subst
autoload -U add-zsh-hook

function() {
    local namespace separator modified_time_fmt

    # Specify the separator between context and namespace
    zstyle -s ':zsh-kubectl-prompt:' separator separator
    if [[ -z "$separator" ]]; then
        zstyle ':zsh-kubectl-prompt:' separator '/'
    fi

    # Display the current namespace if `namespace` is true
    zstyle -s ':zsh-kubectl-prompt:' namespace namespace
    if [[ -z "$namespace" ]]; then
        zstyle ':zsh-kubectl-prompt:' namespace true
    fi

    # Check the stat command because it has a different syntax between GNU coreutils and FreeBSD.
    if stat --help >/dev/null 2>&1; then
        modified_time_fmt='-c%y' # GNU coreutils
    else
        modified_time_fmt='-f%m' # FreeBSD
    fi
    zstyle ':zsh-kubectl-prompt:' modified_time_fmt $modified_time_fmt
}

add-zsh-hook precmd _zsh_kubectl_prompt_precmd
function _zsh_kubectl_prompt_precmd() {
    local kubeconfig config updated_at now context namespace ns separator modified_time_fmt

    kubeconfig="$HOME/.kube/config"
    if [[ -n "$KUBECONFIG" ]]; then
        kubeconfig="$KUBECONFIG"
    fi

    zstyle -s ':zsh-kubectl-prompt:' modified_time_fmt modified_time_fmt

    # KUBECONFIG environment variable can hold a list of kubeconfig files that is colon-delimited.
    # Therefore, if KUBECONFIG has been held multiple files, each files need to be checked.
    while read -d ":" config; do
        if ! now="${now}$(stat -L $modified_time_fmt "$config" 2>/dev/null)"; then
            ZSH_KUBECTL_PROMPT="$config doesn't exist"
            return 1
        fi
    done <<< "${kubeconfig}:"

    zstyle -s ':zsh-kubectl-prompt:' updated_at updated_at
    if [[ "$updated_at" == "$now" ]]; then
        return 0
    fi
    zstyle ':zsh-kubectl-prompt:' updated_at "$now"

    # Set environment variable if context is not set
    if ! context="$(kubectl config current-context 2>/dev/null)"; then
        ZSH_KUBECTL_PROMPT="current-context is not set"
        return 1
    fi

    ZSH_KUBECTL_USER="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.user}")"
    ZSH_KUBECTL_CONTEXT="${context}"
    ns="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.namespace}")"
    [[ -z "$ns" ]] && ns="default"
    ZSH_KUBECTL_NAMESPACE="${ns}"

    # Specify the entry before prompt (default empty)
    zstyle -s ':zsh-kubectl-prompt:' preprompt preprompt
    # Specify the entry after prompt (default empty)
    zstyle -s ':zsh-kubectl-prompt:' postprompt postprompt

    # Set environment variable without namespace
    zstyle -s ':zsh-kubectl-prompt:' namespace namespace
    if [[ "$namespace" != true ]]; then
        ZSH_KUBECTL_PROMPT="${preprompt}${context}${postprompt}"
        return 0
    fi

    zstyle -s ':zsh-kubectl-prompt:' separator separator
    ZSH_KUBECTL_PROMPT="${preprompt}${context}${separator}${ns}${postprompt}"

    return 0
}
