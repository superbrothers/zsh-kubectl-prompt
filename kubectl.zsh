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
    local kubeconfig updated_at now context namespace ns separator modified_time_fmt

    kubeconfig="$HOME/.kube/config"
    if [[ -n "$KUBECONFIG" ]]; then
        kubeconfig="$KUBECONFIG"
    fi

    zstyle -s ':zsh-kubectl-prompt:' modified_time_fmt modified_time_fmt
    if ! now="$(stat -L $modified_time_fmt "$kubeconfig" 2>/dev/null)"; then
        ZSH_KUBECTL_PROMPT="kubeconfig is not found"
        return 1
    fi

    zstyle -s ':zsh-kubectl-prompt:' updated_at updated_at
    if [[ "$updated_at" == "$now" ]]; then
        return 0
    fi
    zstyle ':zsh-kubectl-prompt:' updated_at "$now"

    if ! context="$(kubectl config current-context 2>/dev/null)"; then
        ZSH_KUBECTL_PROMPT="current-context is not set"
        return 1
    fi

    zstyle -s ':zsh-kubectl-prompt:' namespace namespace
    if [[ "$namespace" != true ]]; then
        ZSH_KUBECTL_PROMPT="${context}"
        return 0
    fi

    ns="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.namespace}")"
    [[ -z "$ns" ]] && ns="default"

    zstyle -s ':zsh-kubectl-prompt:' separator separator
    ZSH_KUBECTL_PROMPT="${context}${separator}${ns}"

    return 0
}
