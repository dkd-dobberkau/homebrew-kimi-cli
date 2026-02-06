class KimiCli < Formula
  desc "AI agent CLI for software development tasks and shell operations"
  homepage "https://github.com/MoonshotAI/kimi-cli"
  url "https://files.pythonhosted.org/packages/b0/0a/ae91e92d800a9be5f76463fd5a06db8739f60b6a59412aff5eb2155e69b2/kimi_cli-1.8.0.tar.gz"
  sha256 "8d50c15d7d64849dd2af672b5ebde44b7efd8190d22b86fa1fc4f370b93dfcf1"
  license "MIT"

  depends_on "python@3.13"

  def install
    python3 = Formula["python@3.13"].opt_bin/"python3.13"

    # Create isolated virtualenv (pip install happens in post_install
    # to avoid Homebrew's Mach-O relocation failing on compiled extensions
    # like cryptography's Rust bindings)
    system python3, "-m", "venv", libexec

    # Create wrapper script for the kimi binary
    (bin/"kimi").write <<~BASH
      #!/bin/bash
      export PATH="#{libexec}/bin:$PATH"
      exec "#{libexec}/bin/kimi" "$@"
    BASH
  end

  def post_install
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", "--no-cache-dir", "kimi-cli==1.8.0"
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
