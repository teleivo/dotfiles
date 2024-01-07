package main

import (
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestName(t *testing.T) {
	var want, got int
	var method string
	var in string
  if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("%s(%q) mismatch (-want +got):\n%s", method, tc.in, diff)
  }
}
