// mainly for snippet development purposes
package main

func main() {
}

type free struct{}

func (f free) me() (string, error) {
	switch "" {
	case "":
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
