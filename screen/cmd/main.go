package main

import (
	"fmt"
	"io"
	"os"
	"syscall"
)

func main() {
	if err := run(os.Stdout); err != nil {
		fmt.Fprintf(os.Stderr, "exited due to: %v\n", err)
		os.Exit(1)
	}
}

func run(w io.Writer) error {
	fd, err := syscall.InotifyInit()
	if err != nil {
		return fmt.Errorf("error initializing inotify: %v\n", err)
	}
	defer syscall.Close(fd)

	card := "card1-DP-2"
	displayPath := "/sys/class/drm/" + card + "/status"

	_, err = syscall.InotifyAddWatch(fd, displayPath,
		syscall.IN_MODIFY|syscall.IN_ATTRIB|syscall.IN_CLOSE_WRITE)
	if err != nil {
		return fmt.Errorf("error adding watch: %v\n", err)
	}

	if status, err := os.ReadFile(displayPath); err == nil {
		fmt.Fprintf(w, "initial state of %q=%s", card, status)
	}

	fmt.Println("Monitoring display changes... (Ctrl+C to stop)")

	buffer := make([]byte, syscall.SizeofInotifyEvent+256)
	for {
		n, err := syscall.Read(fd, buffer)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error reading events: %v\n", err)
			continue
		}

		if n > 0 {
			status, err := os.ReadFile(displayPath)
			if err != nil {
				fmt.Fprintf(os.Stderr, "error reading status: %v\n", err)
				continue
			}
			fmt.Fprintf(w, "updated state of %q=%s", card, status)
		}
	}
	// gsettings set org.gnome.desktop.interface text-scaling-factor 1.6
}
