all: sync install

sync:
	mkdir ~/bin
	mkdir -p ~/.config/alacritty

	[ -f ~/.config/alacritty/alacritty.yml ] || ln -s $(PWD)/alacritty.yml ~/.config/alacritty/alacritty.yml
	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.vim/coc-settings.json ] || ln -s $(PWD)/coc-settings.json ~/.vim/coc-settings.json
	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ -f ~/bin/tat ] || ln -s $(PWD)/tat ~/bin/tat
	[ -f ~/.alias ] || ln -s $(PWD)/alias ~/.alias
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.gitignore ] || ln -s $(PWD)/gitignore ~/.gitignore
	[ -f ~/.gitconfig-defaults ] || ln -s $(PWD)/gitconfig-defaults ~/.gitconfig-defaults
	[ -f ~/.gitconfig-user-personal ] || ln -s $(PWD)/gitconfig-user-personal ~/.gitconfig-user-personal
	[ -f ~/.gitconfig ] || ln -s $(PWD)/gitconfig ~/.gitconfig

install:
	vim +PlugUpgrade +PlugInstall +qall

clean:
	rm -f ~/bin
	rm -f ~/.config/alacritty/alacritty.yml
	rm -f ~/.vimrc
	rm -f ~/.tmux.conf
	rm -f ~/.alias
	rm -f ~/.zshrc
	rm -f ~/.gitignore
	rm -f ~/.gitconfig-defaults
	rm -f ~/.gitconfig-user-personal
	rm -f ~/.gitconfig
