// mainly for snippet development purposes
package main

import "fmt"

func main() {
}

type free struct{}

func (f free) me() (string, error) {
	var err error
	if err != nil {
		return "", fmt.Errorf("foo: %w", err)
	}
	return "", nil
}

func foo() error {
	return nil
}

func withError() (int, error) {
	return 0, nil
}

func withoutError() (int, *int, map[string]*int) {

	return 0, nil, nil

}

func noResult() {
	return
}
