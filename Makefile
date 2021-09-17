all: sync install

sync:
	mkdir -p ~/.local/share/eclipse

	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ -f ~/.alias ] || ln -s $(PWD)/alias ~/.alias
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.oh-my-zsh/themes/teleivo.zsh-theme ] || ln -s $(PWD)/teleivo.zsh-theme ~/.oh-my-zsh/themes/teleivo.zsh-theme

clean:
	rm -f ~/.tmux.conf
	rm -f ~/.alias
	rm -f ~/.oh-my-zsh/themes/teleivo.zsh-theme
	rm -f ~/.zshrc
