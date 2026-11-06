package credentials

import "testing"

// Test addresses are fixed, non-secret fixtures used only by the local Gno VM.
const (
	testAdminAddress   = "g1ecely4gjy0yl6s9kt409ll330q9hk2lj9ls3ec"
	testIssuerAddress  = "g1jg8mtutu9khhfwc4nxmuhcpftf0pajdhfvsqf5"
	testOtherAddress   = "g1x8q4z3v8w0p0x6j0y8w6c8k2m4n6p8q0r2s4t"
	testAttackerAddr   = "g1m8q2v6c0x4z8p2s6w0k4n8j2m6q0v4c8x2z6p"
)

func setTestCaller(caller address) {
	testing.SetOriginCaller(caller)
}

func expectPanic(t *testing.T, fn func()) {
	t.Helper()
	defer func() {
		if recover() == nil {
			t.Fatal("expected call to panic")
		}
	}()
	fn()
}

func TestRequestIssuerCreatesInactiveRequest(t *testing.T) {
	issuerAddress := address(testIssuerAddress)
	setTestCaller(issuerAddress)

	RequestIssuer(cross, "Credora Test Institute")

	issuer := GetIssuer(issuerAddress)
	if issuer.Address != issuerAddress {
		t.Fatalf("expected issuer address %s, got %s", issuerAddress, issuer.Address)
	}
	if issuer.Name != "Credora Test Institute" {
		t.Fatalf("expected issuer name to be preserved, got %q", issuer.Name)
	}
	if issuer.Active {
		t.Fatal("new issuer request must remain inactive until admin approval")
	}
	if IsApprovedIssuer(issuerAddress) {
		t.Fatal("new issuer request must not be approved")
	}
}

func TestRequestIssuerRejectsEmptyName(t *testing.T) {
	issuerAddress := address(testOtherAddress)
	setTestCaller(issuerAddress)

	expectPanic(t, func() {
		RequestIssuer(cross, "")
	})

	if issuers[issuerAddress] != nil {
		t.Fatal("empty issuer name must not create a request")
	}
}

func TestRequestIssuerRejectsDuplicateRequest(t *testing.T) {
	issuerAddress := address(testIssuerAddress)
	setTestCaller(issuerAddress)
	RequestIssuer(cross, "Original Institute")

	expectPanic(t, func() {
		RequestIssuer(cross, "Replacement Institute")
	})

	issuer := GetIssuer(issuerAddress)
	if issuer.Name != "Original Institute" {
		t.Fatalf("duplicate request changed stored name to %q", issuer.Name)
	}
	if issuer.Active {
		t.Fatal("duplicate request must not activate issuer")
	}
}

func TestDifferentAddressesCanRequestIssuerStatus(t *testing.T) {
	firstAddress := address(testIssuerAddress)
	secondAddress := address(testOtherAddress)

	setTestCaller(firstAddress)
	RequestIssuer(cross, "First Institute")

	setTestCaller(secondAddress)
	RequestIssuer(cross, "Second Institute")

	if GetIssuer(firstAddress).Name != "First Institute" {
		t.Fatal("first issuer request was not stored independently")
	}
	if GetIssuer(secondAddress).Name != "Second Institute" {
		t.Fatal("second issuer request was not stored independently")
	}
}

func TestAdminCanApproveIssuer(t *testing.T) {
	admin = address(testAdminAddress)
	issuerAddress := address(testIssuerAddress)

	setTestCaller(issuerAddress)
	RequestIssuer(cross, "Approval Test Institute")

	setTestCaller(admin)
	ApproveIssuer(cross, issuerAddress)

	issuer := GetIssuer(issuerAddress)
	if !issuer.Active {
		t.Fatal("administrator approval should activate issuer")
	}
	if !IsApprovedIssuer(issuerAddress) {
		t.Fatal("approved issuer should be reported as approved")
	}
}

func TestNonAdminCannotApproveIssuer(t *testing.T) {
	admin = address(testAdminAddress)
	issuerAddress := address(testIssuerAddress)

	setTestCaller(issuerAddress)
	RequestIssuer(cross, "Unauthorized Approval Test")

	setTestCaller(address(testAttackerAddr))
	expectPanic(t, func() {
		ApproveIssuer(cross, issuerAddress)
	})

	if IsApprovedIssuer(issuerAddress) {
		t.Fatal("unauthorized approval must not activate issuer")
	}
}

func TestAdminCannotApproveUnknownIssuer(t *testing.T) {
	admin = address(testAdminAddress)
	setTestCaller(admin)

	expectPanic(t, func() {
		ApproveIssuer(cross, address(testOtherAddress))
	})
}

func TestAdminCanDisableIssuer(t *testing.T) {
	admin = address(testAdminAddress)
	issuerAddress := address(testIssuerAddress)

	setTestCaller(issuerAddress)
	RequestIssuer(cross, "Disable Test Institute")

	setTestCaller(admin)
	ApproveIssuer(cross, issuerAddress)
	DisableIssuer(cross, issuerAddress)

	if IsApprovedIssuer(issuerAddress) {
		t.Fatal("disabled issuer must no longer be approved")
	}
	if GetIssuer(issuerAddress).Name != "Disable Test Institute" {
		t.Fatal("disabling issuer must preserve its registry record")
	}
}

func TestNonAdminCannotDisableIssuer(t *testing.T) {
	admin = address(testAdminAddress)
	issuerAddress := address(testIssuerAddress)

	setTestCaller(issuerAddress)
	RequestIssuer(cross, "Unauthorized Disable Test")
	setTestCaller(admin)
	ApproveIssuer(cross, issuerAddress)

	setTestCaller(address(testAttackerAddr))
	expectPanic(t, func() {
		DisableIssuer(cross, issuerAddress)
	})

	if !IsApprovedIssuer(issuerAddress) {
		t.Fatal("unauthorized disable must leave issuer active")
	}
}
