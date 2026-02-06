class KimiCli < Formula
  desc "AI agent CLI for software development tasks and shell operations"
  homepage "https://github.com/MoonshotAI/kimi-cli"
  url "https://files.pythonhosted.org/packages/b0/0a/ae91e92d800a9be5f76463fd5a06db8739f60b6a59412aff5eb2155e69b2/kimi_cli-1.8.0.tar.gz"
  sha256 "8d50c15d7d64849dd2af672b5ebde44b7efd8190d22b86fa1fc4f370b93dfcf1"
  license "MIT"

  depends_on "python@3.13"

  # Skip relocation/cleaning of the virtualenv — compiled Python extensions
  # (e.g. cryptography's Rust bindings) have compact Mach-O headers that
  # Homebrew's relocator cannot rewrite.
  skip_clean "libexec"

  def install
    python3 = Formula["python@3.13"].opt_bin/"python3.13"

    # Create isolated virtualenv
    venv_dir = libexec
    system python3, "-m", "venv", venv_dir
    venv_pip = venv_dir/"bin/pip"

    # Upgrade pip and install kimi-cli with all dependencies
    system venv_pip, "install", "--upgrade", "pip"
    system venv_pip, "install", "--no-cache-dir", "kimi-cli==1.8.0"

    # Link the kimi binary into Homebrew's bin
    (bin/"kimi").write_env_script(
      venv_dir/"bin/kimi",
      PATH: "#{venv_dir}/bin:$PATH"
    )
  end

  def caveats
    <<~EOS
      To get started, run:
        kimi

      You may need to log in first:
        kimi (then use /login inside the CLI)

      For MCP server management:
        kimi mcp add|list|remove

      For ACP (Agent Client Protocol) server mode:
        kimi acp
    EOS
  end

  test do
    output = shell_output("#{bin}/kimi --help 2>&1", 0)
    assert_match(/kimi/i, output)
  end
end
