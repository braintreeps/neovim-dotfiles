# neovim-dotfiles

Welcome to the Braintree Neovim configuration!

These dotfiles incorporate many of the same features that exist in our [vim_dotfiles][vim_dotfiles] repository, plus many new features that are only available in Neovim! **We are currently supporting Neovim >= 0.11**.

<img width="1215" height="1148" alt="image" src="https://github.com/user-attachments/assets/fc1dd4e9-4724-4546-9c01-ae0a69efaa4f" />
<img width="1094" height="975" alt="image" src="https://github.com/user-attachments/assets/4ee3fe31-8fa4-4716-92ad-69252b502443" />

## 🔍 Main differences

- 💤[`lazy.nvim`][lazy.nvim] for managing plugins, and lazy-loading them.
- 🔏 `Lockfile` for plugins and tools to ensure compatibility.
- 🆕 Use modern, maintained Neovim-variants of traditional Vim plugins.
- 💻 Leverage advanced tooling, such as [LSPs](./docs/LSP_GUIDE.md), [Treesitter](./docs/TREESITTER.md) and many more things!

## 🤩 Getting started

Check out our [GETTING_STARTED](./docs/GETTING_STARTED.md) guide for your initial tour!

To confirm you're ready to get started, try launching neovim with the `nvim`
command and pressing the `<Leader>` key (`\` by default). You should see a
small floating window appear in the bottom-right corner of the screen. If you
don't see that window pop up, then you'll need to follow the **Installation
Guide** below.

### ✨ Personalization

While these dotfiles aim to be a complete solution and provide a "lingua franca" for Braintree developers, one of the coolest advantages of Neovim is its ease of customization! If you want to change anything about how these base dotfiles behave, or try out new plugins to optimize your personal workflows, head on over to the [`neovim-dotfiles-personal.scaffold`][neovim-dotfiles-personal.scaffold] repo to see how to easily integrate your customizations!

## ⚙️ Installation Guide

- Back up your current Neovim files (if any):

```sh
mv ~/.config/nvim{,.bak}
```

- Clone the dotfiles

```sh
git clone git@github.com:braintreeps/neovim-dotfiles.git ~/.config/nvim
```

- Start Neovim!

```sh
nvim
```

> [!TIP]
> It's recommended to run `:checkhealth` after installation. This will load all plugins, and check if everything is working correctly.

### 👥 Running alongside existing Neovim config

If you have a current Neovim configuration that you use and want to test this one out, you can bootstrap the dotfiles as follows:

1. Clone the repo to a different directory (e.g. `~/.config/btnvim`):

```sh
git clone https://github.com/braintreeps/neovim-dotfiles ~/.config/btnvim
```

2. Tell Neovim to use your custom folder for dotfiles:

```sh
NVIM_APPNAME=btnvim nvim
```

3. Optionally set up an alias in your `~/.zshrc_personal` for ease of access
```sh
alias bvim="NVIM_APPNAME=btnvim nvim"
```

This leverages [Neovim's ability to use different configurations based on XDG environment variables](https://github.com/neovim/neovim/pull/22128).

## 🤝 Contributing

- [GitHub issues](https://github.com/PayPal-Braintree/neovim-dotfiles/issues)
    - Please create for any unexpected behavior, missing behavior, desired improvements, etc. This will help ensure that we can successfully "upgrade" our [vim_dotfiles][vim_dotfiles] to Neovim.
- Pull requests are encouraged!

[vim_dotfiles]: https://github.com/braintreeps/vim_dotfiles
[lazy.nvim]: https://github.com/folke/lazy.nvim
[neovim-dotfiles-personal.scaffold]: https://github.com/braintreeps/neovim-dotfiles-personal.scaffold
[which-key.nvim]: https://github.com/folke/which-key.nvim
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
