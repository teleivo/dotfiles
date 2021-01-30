all: sync install

sync:
	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.alias ] || ln -s $(PWD)/alias ~/.alias
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc
	[ -f ~/.gitignore ] || ln -s $(PWD)/gitignore ~/.gitignore
	[ -f ~/.gitconfig-defaults ] || ln -s $(PWD)/gitconfig-defaults ~/.gitconfig-defaults
	[ -f ~/.gitconfig-user-personal ] || ln -s $(PWD)/gitconfig-user-personal ~/.gitconfig-user-personal
	[ -f ~/.gitconfig ] || ln -s $(PWD)/gitconfig ~/.gitconfig

install:
	vim +PlugUpgrade +PlugInstall +qall

clean:
	rm -f ~/.vimrc
	rm -f ~/.alias
	rm -f ~/.zshrc
	rm -f ~/.gitignore
	rm -f ~/.gitconfig-defaults
	rm -f ~/.gitconfig-user-personal
	rm -f ~/.gitconfig
