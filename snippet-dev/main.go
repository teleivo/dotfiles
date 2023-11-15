// mainly for snippet development purposes
package main

import "strconv"

func main() {
}

type free struct{}

func (f free) me() (string, error) {
}

func foo() (err error) {
	return nil
}

func withError() (int, error) {
	return 0, nil
}

func withoutError() (int, *int, map[string]*int) {
	return 0, nil, nil
}

func noResult() {
}
