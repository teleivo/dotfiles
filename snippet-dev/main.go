// mainly for snippet development purposes
package main

func main() {
}

type free struct{}

func (f free) me() (string, error) {
  return "", nil
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
  return
}
