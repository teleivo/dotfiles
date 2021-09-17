all: sync install

sync:
	mkdir -p ~/.local/share/eclipse

	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.vim/coc-settings.json ] || ln -s $(PWD)/coc-settings.json ~/.vim/coc-settings.json
	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ -f ~/.alias ] || ln -s $(PWD)/alias ~/.alias
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.oh-my-zsh/themes/teleivo.zsh-theme ] || ln -s $(PWD)/teleivo.zsh-theme ~/.oh-my-zsh/themes/teleivo.zsh-theme

install:
	vim +PlugUpgrade +PlugInstall +qall

clean:
	rm -f ~/.vimrc
	rm -f ~/.tmux.conf
	rm -f ~/.alias
	rm -f ~/.oh-my-zsh/themes/teleivo.zsh-theme
	rm -f ~/.zshrc
