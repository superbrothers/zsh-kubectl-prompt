# zsh-kubectl-prompt

This script displays information about the kubectl current context and namespace in zsh prompt.

![Screenshot](./images/screenshot001.png)

## Usage

1. Clone this repository.
2. Source the `kubectl.zsh` from your `~/.zshrc` config file, and configure your prompt.
    ```sh
    autoload -U colors; colors
    source /path/to/zsh-kubectl-prompt/kubectl.zsh
    RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
    ```

## Customization

Change the separator between context and namespace:
```sh
zstyle ':zsh-kubectl-prompt:' separator '|'
```

Does not display the current namespace:
```sh
zstyle ':zsh-kubectl-prompt:' namespace false
```

## License

This script is released under the MIT License.
