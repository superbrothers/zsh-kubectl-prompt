class ZshKubectlPrompt < Formula
  desc "Display information about the kubectl current context and namespace in zsh prompt."
  homepage "https://github.com/superbrothers/zsh-kubectl-prompt"
  version "v1.0.0"
  url "https://github.com/superbrothers/zsh-kubectl-prompt.git", tag: version
  head "https://github.com/superbrothers/zsh-kubectl-prompt.git", branch: "master"

  def install
    (prefix/"etc/zsh-kubectl-prompt").install "kubectl.zsh"
  end

  def caveats; <<~EOS
    Source the `kubectl.zsh` from your `~/.zshrc` config file, and configure your prompt as follows:
      autoload -U colors; colors
      source #{etc}/zsh-kubectl-prompt/kubectl.zsh
      RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'
    EOS
  end
end
