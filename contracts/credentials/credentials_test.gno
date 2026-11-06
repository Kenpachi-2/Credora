package credentials

import (
	"testing"
	"gno.land/p/nt/testutils/v0"
)

// Deterministic addresses for isolated test callers.
func testAddress(label string) address {
	return testutils.TestAddress(label)
}

func setTestCaller(cur realm, caller address) {
	// Construct the credentials code realm while the test is still executing
	// in the credentials realm. NewCodeRealm cannot be created from a user realm.
	codeRealm := testing.NewCodeRealm(cur.PkgPath())

	// Model the external user entering the credentials realm.
	testing.SetRealm(testing.NewUserRealm(caller))
	testing.SetRealm(codeRealm)
}

func expectPanic(t *testing.T, fn func()) {
	if revive(fn) == nil {
		t.Fatal("expected call to panic")
	}
}

func TestRequestIssuerCreatesInactiveRequest(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-main")
	setTestCaller(cur, issuerAddress)

	RequestIssuer(cur, "Credora Test Institute")

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

func TestRequestIssuerRejectsEmptyName(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-empty")
	setTestCaller(cur, issuerAddress)

	expectPanic(t, func() {
		RequestIssuer(cur, "")
	})

	if issuers[issuerAddress] != nil {
		t.Fatal("empty issuer name must not create a request")
	}
}

func TestRequestIssuerRejectsDuplicateRequest(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-duplicate")
	setTestCaller(cur, issuerAddress)
	RequestIssuer(cur, "Original Institute")

	expectPanic(t, func() {
		RequestIssuer(cur, "Replacement Institute")
	})

	issuer := GetIssuer(issuerAddress)
	if issuer.Name != "Original Institute" {
		t.Fatalf("duplicate request changed stored name to %q", issuer.Name)
	}
	if issuer.Active {
		t.Fatal("duplicate request must not activate issuer")
	}
}

func TestDifferentAddressesCanRequestIssuerStatus(cur realm, t *testing.T) {
	firstAddress := testAddress("issuer-first")
	secondAddress := testAddress("issuer-second")

	setTestCaller(cur, firstAddress)
	RequestIssuer(cur, "First Institute")

	setTestCaller(cur, secondAddress)
	RequestIssuer(cur, "Second Institute")

	if GetIssuer(firstAddress).Name != "First Institute" {
		t.Fatal("first issuer request was not stored independently")
	}
	if GetIssuer(secondAddress).Name != "Second Institute" {
		t.Fatal("second issuer request was not stored independently")
	}
}

func TestAdminCanApproveIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	issuerAddress := testAddress("issuer-approval")

	setTestCaller(cur, issuerAddress)
	RequestIssuer(cur, "Approval Test Institute")

	setTestCaller(cur, admin)
	ApproveIssuer(cur, issuerAddress)

	issuer := GetIssuer(issuerAddress)
	if !issuer.Active {
		t.Fatal("administrator approval should activate issuer")
	}
	if !IsApprovedIssuer(issuerAddress) {
		t.Fatal("approved issuer should be reported as approved")
	}
}

func TestNonAdminCannotApproveIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	issuerAddress := testAddress("issuer-unauthorized")

	setTestCaller(cur, issuerAddress)
	RequestIssuer(cur, "Unauthorized Approval Test")

	setTestCaller(cur, testAddress("attacker"))
	expectPanic(t, func() {
		ApproveIssuer(cur, issuerAddress)
	})

	if IsApprovedIssuer(issuerAddress) {
		t.Fatal("unauthorized approval must not activate issuer")
	}
}

func TestAdminCannotApproveUnknownIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	setTestCaller(cur, admin)

	expectPanic(t, func() {
		ApproveIssuer(cur, testAddress("issuer-unknown"))
	})
}

func TestAdminCanDisableIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	issuerAddress := testAddress("issuer-disable")

	setTestCaller(cur, issuerAddress)
	RequestIssuer(cur, "Disable Test Institute")

	setTestCaller(cur, admin)
	ApproveIssuer(cur, issuerAddress)
	DisableIssuer(cur, issuerAddress)

	if IsApprovedIssuer(issuerAddress) {
		t.Fatal("disabled issuer must no longer be approved")
	}
	if GetIssuer(issuerAddress).Name != "Disable Test Institute" {
		t.Fatal("disabling issuer must preserve its registry record")
	}
}

func TestNonAdminCannotDisableIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	issuerAddress := testAddress("issuer-bad-disable")

	setTestCaller(cur, issuerAddress)
	RequestIssuer(cur, "Unauthorized Disable Test")
	setTestCaller(cur, admin)
	ApproveIssuer(cur, issuerAddress)

	setTestCaller(cur, testAddress("attacker"))
	expectPanic(t, func() {
		DisableIssuer(cur, issuerAddress)
	})

	if !IsApprovedIssuer(issuerAddress) {
		t.Fatal("unauthorized disable must leave issuer active")
	}
}
