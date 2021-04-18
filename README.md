# zsh-kubectl-prompt

This script displays information about the kubectl current context and namespace in zsh prompt.

![Screenshot](./images/screenshot001.png)

## Usage

Clone this repository and source the `kubectl.zsh` from your `~/.zshrc` config file, and configure your prompt.

```sh
autoload -U colors; colors
source /path/to/zsh-kubectl-prompt/kubectl.zsh
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
```

Or create different style depending on user, context, namespace.
The plugin creates 4 variables:
* ZSH_KUBECTL_CONTEXT
* ZSH_KUBECTL_NAMESPACE
* ZSH_KUBECTL_PROMPT
* ZSH_KUBECTL_USER

For example, make the prompt red when the username matches admin.
```sh
autoload -U colors; colors
source /path/to/zsh-kubectl-prompt/kubectl.zsh
function right_prompt() {
  local color="blue"

  if [[ "$ZSH_KUBECTL_USER" =~ "admin" ]]; then
    color=red
  fi

  echo "%{$fg[$color]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}"
}
RPROMPT='$(right_prompt)'
```

Also you can install with homebrew.

```console
$ brew tap superbrothers/zsh-kubectl-prompt
$ brew install zsh-kubectl-prompt
```

## Customization

Change the separator between context and namespace:

```sh
zstyle ':zsh-kubectl-prompt:' separator '|'
```

Add custom character before the prompt:

```sh
zstyle ':zsh-kubectl-prompt:' preprompt '<'
```

Add custom character after the prompt:

```sh
zstyle ':zsh-kubectl-prompt:' postprompt '>'
```

Does not display the current namespace:

```sh
zstyle ':zsh-kubectl-prompt:' namespace false
```

Use another binary instead of `kubectl` to get the information (e.g. `oc`):

```sh
zstyle ':zsh-kubectl-prompt:' binary 'oc'
```

## With a plugin manager

If you use [zgen](https://github.com/tarjoilija/zgen), load this repository as follows:

```sh
source "${HOME}/.zgen/zgen.zsh"

# if the init script doesn't exist
if ! zgen saved; then
    # specify plugins here
    zgen load superbrothers/zsh-kubectl-prompt

    # generate the init script from plugins above
    zgen save
fi

autoload -U colors; colors
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
```

If you use [antigen](https://github.com/zsh-users/antigen), load this repository as follows:

```sh
source /path-to-antigen/antigen.zsh

# load this plugin
antigen bundle superbrothers/zsh-kubectl-prompt

# tell antigen that you're done.
antigen apply

autoload -U colors; colors
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
```

If you use [oh-my-zsh](https://ohmyz.sh/), load this repository as follows:

1. Clone the repo into oh-my-zsh custom plugins folder

```sh
git clone git@github.com:superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt
```

2. Activate the plugin your `.zshrc` by appending it to the plugin section

```sh
plugins=( [plugins...] zsh-kubectl-prompt)
```

3. Configure your prompt (or check how to customize the theme plugin you are using)
```sh
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
```

> **Note:** Remember to source the `.zshrc` or restart your shell after step 2

## License

This script is released under the MIT License.
