setopt prompt_subst
autoload -U add-zsh-hook

function() {
    local namespace separator

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
}

add-zsh-hook precmd _zsh_kubectl_prompt_precmd
function _zsh_kubectl_prompt_precmd() {
    local kubeconfig updated_at now context namespace ns separator

    kubeconfig="$HOME/.kube/config"
    if [[ -n "$KUBECONFIG" ]]; then
        kubeconfig="$KUBECONFIG"
    fi

    zstyle -s ':zsh-kubectl-prompt:' updated_at updated_at
    if [[ $(uname) == "Linux" ]]; then
        now="$(stat -c '%y' "$kubeconfig" 2>/dev/null)"
    elif [[ $(uname) == "Darwin" ]]; then
        now="$(stat -f '%m' "$kubeconfig" 2>/dev/null)"
    fi
    if ! [[ -n $now ]]; then
        ZSH_KUBECTL_PROMPT="kubeconfig is not found"
        return 1
    fi

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
