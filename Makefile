all: sync install

sync:
	mkdir -p ~/.local/share/eclipse

	[ -f ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf

clean:
	rm -f ~/.tmux.conf
