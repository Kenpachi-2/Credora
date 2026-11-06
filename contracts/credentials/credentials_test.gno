package credentials

import (
	"testing"

	"gno.land/p/nt/testutils/v0"
)

// Deterministic addresses for isolated test callers.
func testAddress(label string) address {
	return testutils.TestAddress(label)
}

func expectPanic(t *testing.T, fn func()) {
	if revive(fn) == nil {
		t.Fatal("expected call to panic")
	}
}

func TestRequestIssuerCreatesInactiveRequest(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-main")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	RequestIssuer(cross(cur), "Credora Test Institute")

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
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	expectPanic(t, func() {
		RequestIssuer(cross(cur), "")
	})

	if issuers[issuerAddress] != nil {
		t.Fatal("empty issuer name must not create a request")
	}
}

func TestRequestIssuerRejectsDuplicateRequest(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-duplicate")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Original Institute")

	expectPanic(t, func() {
		RequestIssuer(cross(cur), "Replacement Institute")
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

	testing.SetRealm(testing.NewUserRealm(firstAddress))
	RequestIssuer(cross(cur), "First Institute")

	testing.SetRealm(testing.NewUserRealm(secondAddress))
	RequestIssuer(cross(cur), "Second Institute")

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

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Approval Test Institute")

	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)

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

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Unauthorized Approval Test")

	testing.SetRealm(testing.NewUserRealm(testAddress("attacker")))
	expectPanic(t, func() {
		ApproveIssuer(cross(cur), issuerAddress)
	})

	if IsApprovedIssuer(issuerAddress) {
		t.Fatal("unauthorized approval must not activate issuer")
	}
}

func TestAdminCannotApproveUnknownIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	testing.SetRealm(testing.NewUserRealm(admin))

	expectPanic(t, func() {
		ApproveIssuer(cross(cur), testAddress("issuer-unknown"))
	})
}

func TestAdminCanDisableIssuer(cur realm, t *testing.T) {
	admin = testAddress("admin")
	issuerAddress := testAddress("issuer-disable")

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Disable Test Institute")

	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	DisableIssuer(cross(cur), issuerAddress)

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

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Unauthorized Disable Test")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)

	testing.SetRealm(testing.NewUserRealm(testAddress("attacker")))
	expectPanic(t, func() {
		DisableIssuer(cross(cur), issuerAddress)
	})

	if !IsApprovedIssuer(issuerAddress) {
		t.Fatal("unauthorized disable must leave issuer active")
	}
}

func TestApprovedIssuerCanIssueCredential(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-can-issue")
	holderAddress := testAddress("credential-holder")
	admin = testAddress("admin-can-approve")

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Credential Issuer")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	IssueCredential(cross(cur), "CRED-ISSUE-001", holderAddress, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0)

	credential := GetCredential("CRED-ISSUE-001")
	if credential.Issuer != issuerAddress || credential.Holder != holderAddress {
		t.Fatal("issued credential must preserve issuer and holder addresses")
	}
	if credential.Revoked || !IsCredentialValid("CRED-ISSUE-001") {
		t.Fatal("newly issued credential should be valid and not revoked")
	}
}

func TestUnapprovedIssuerCannotIssueCredential(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-not-approved")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Pending Institute")

	expectPanic(t, func() {
		IssueCredential(cross(cur), "CRED-UNAPPROVED", testAddress("holder-unapproved"), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0)
	})
}

func TestOnlyIssuingOrganisationCanRevokeCredential(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-revoke-owner")
	holderAddress := testAddress("holder-revocation")
	admin = testAddress("admin-revocation")

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Revocation Institute")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	IssueCredential(cross(cur), "CRED-REVOKE-001", holderAddress, "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", 0)

	testing.SetRealm(testing.NewUserRealm(testAddress("unrelated-revoker")))
	expectPanic(t, func() { RevokeCredential(cross(cur), "CRED-REVOKE-001") })
	if !IsCredentialValid("CRED-REVOKE-001") {
		t.Fatal("unauthorised revocation must not invalidate credential")
	}

	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RevokeCredential(cross(cur), "CRED-REVOKE-001")
	if IsCredentialValid("CRED-REVOKE-001") || !GetCredential("CRED-REVOKE-001").Revoked {
		t.Fatal("issuer revocation must mark credential invalid")
	}
	expectPanic(t, func() { RevokeCredential(cross(cur), "CRED-REVOKE-001") })
}

func TestIssueCredentialRejectsMalformedDigest(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-bad-digest")
	admin = testAddress("admin-bad-digest")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Digest Institute")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	expectPanic(t, func() {
		IssueCredential(cross(cur), "CRED-BAD-DIGEST", testAddress("holder-bad-digest"), "not-a-sha256-digest", 0)
	})
}

func TestIssueCredentialRejectsPastExpiry(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-expired")
	admin = testAddress("admin-expired")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Expiry Institute")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	expectPanic(t, func() {
		IssueCredential(cross(cur), "CRED-PAST-EXPIRY", testAddress("holder-expired"), "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc", 1)
	})
}

func TestRequestIssuerRejectsWhitespaceOnlyName(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-blank-name")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	expectPanic(t, func() {
		RequestIssuer(cross(cur), "   \t\n")
	})
	if issuers[issuerAddress] != nil {
		t.Fatal("blank issuer name must not create a request")
	}
}

func TestIssueCredentialRejectsWhitespaceOnlyID(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-blank-id")
	admin = testAddress("admin-blank-id")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Blank ID Institute")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	expectPanic(t, func() {
		IssueCredential(cross(cur), "   ", testAddress("holder-blank-id"), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0)
	})
}

func TestIssueCredentialRejectsDuplicateID(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-dup-id")
	admin = testAddress("admin-dup-id")
	holderAddress := testAddress("holder-dup-id")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Duplicate ID Institute")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	IssueCredential(cross(cur), "CRED-DUPLICATE", holderAddress, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0)

	expectPanic(t, func() {
		IssueCredential(cross(cur), "CRED-DUPLICATE", holderAddress, "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb", 0)
	})
	if GetCredential("CRED-DUPLICATE").DocumentHash != "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" {
		t.Fatal("duplicate credential ID must not overwrite the original record")
	}
}

func TestDisabledIssuerCannotIssueCredential(cur realm, t *testing.T) {
	issuerAddress := testAddress("issuer-disabled")
	admin = testAddress("admin-disabled")
	testing.SetRealm(testing.NewUserRealm(issuerAddress))
	RequestIssuer(cross(cur), "Disabled Institute")
	testing.SetRealm(testing.NewUserRealm(admin))
	ApproveIssuer(cross(cur), issuerAddress)
	DisableIssuer(cross(cur), issuerAddress)
	testing.SetRealm(testing.NewUserRealm(issuerAddress))

	expectPanic(t, func() {
		IssueCredential(cross(cur), "CRED-DISABLED", testAddress("holder-disabled"), "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 0)
	})
}

func TestExpiredCredentialIsNotValid(cur realm, t *testing.T) {
	_ = cur
	credentials["CRED-EXPIRED-STATUS"] = &Credential{
		ID:        "CRED-EXPIRED-STATUS",
		ExpiresAt: 1,
	}
	if IsCredentialValid("CRED-EXPIRED-STATUS") {
		t.Fatal("expired credential must not be considered valid")
	}
}
