all: sync

sync:
	[ -f ~/.vimrc ] || ln -s $(PWD)/vimrc ~/.vimrc
	[ -f ~/.alias ] || ln -s $(PWD)/alias ~/.alias
	[ -f ~/.zshrc ] || ln -s $(PWD)/zshrc ~/.zshrc

clean:
	rm -f ~/.vimrc
	rm -f ~/.alias
	rm -f ~/.zshrc
