package credentials

import "testing"

func TestValidSHA256Hex(t *testing.T) {
	valid := "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
	if !isValidSHA256Hex(valid) {
		t.Fatal("expected valid SHA-256 hex digest to pass")
	}
}

func TestRejectsInvalidSHA256HexLength(t *testing.T) {
	if isValidSHA256Hex("abcd") {
		t.Fatal("expected short digest to fail")
	}
}

func TestRejectsUppercaseSHA256Hex(t *testing.T) {
	invalid := "ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789"
	if isValidSHA256Hex(invalid) {
		t.Fatal("expected uppercase digest to fail")
	}
}

func TestRejectsNonHexSHA256Digest(t *testing.T) {
	invalid := "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
	if isValidSHA256Hex(invalid) {
		t.Fatal("expected non-hex digest to fail")
	}
}
