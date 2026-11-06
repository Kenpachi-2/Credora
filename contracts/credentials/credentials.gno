package credentials

import "time"

// admin is captured from the deployer during one-time realm initialisation.
var admin address

var issuers = map[address]*Issuer{}
var credentials = map[string]*Credential{}

// Issuer represents an organisation that has requested permission to issue
// credentials. Approval is a governance decision made by the registry admin.
type Issuer struct {
	Address address
	Name    string
	Active  bool
}

// Credential contains only the minimum public verification record.
// Never put names, certificate files, or other personal data in this struct.
type Credential struct {
	ID           string
	Issuer       address
	Holder       address
	DocumentHash string
	IssuedAt     int64
	ExpiresAt    int64
	Revoked      bool
}

// Gno provides the deployer as the previous realm during init. Capture only
// its address; realm handles are ephemeral and must not be persisted.
func init(cur realm) {
	admin = cur.Previous().Address()
}

func requireCurrent(cur realm) {
	if !cur.IsCurrent() {
		panic("invalid realm context")
	}
}

func requireAdmin(cur realm) {
	requireCurrent(cur)
	if cur.Previous().Address() != admin {
		panic("permission denied: registry admin required")
	}
}

// RequestIssuer lets an organisation request issuer status. A request is
// inactive until the registry administrator approves it.
func RequestIssuer(cur realm, name string) {
	requireCurrent(cur)
	caller := cur.Previous().Address()
	if name == "" {
		panic("issuer name is required")
	}
	if issuers[caller] != nil {
		panic("issuer request already exists")
	}
	issuers[caller] = &Issuer{Address: caller, Name: name, Active: false}
}

// ApproveIssuer activates an issuer after off-chain due diligence.
func ApproveIssuer(cur realm, issuerAddress address) {
	requireAdmin(cur)
	issuer := issuers[issuerAddress]
	if issuer == nil {
		panic("issuer request not found")
	}
	issuer.Active = true
}

// DisableIssuer prevents an organisation from issuing further credentials.
// Existing credentials remain in the registry and can still be inspected.
func DisableIssuer(cur realm, issuerAddress address) {
	requireAdmin(cur)
	issuer := issuers[issuerAddress]
	if issuer == nil {
		panic("issuer not found")
	}
	issuer.Active = false
}

// IssueCredential records a credential digest. The actual document and
// identifying claims must be delivered and stored off-chain.
func IssueCredential(cur realm, id string, holder address, documentHash string, expiresAt int64) {
	requireCurrent(cur)
	issuerAddress := cur.Previous().Address()
	issuer := issuers[issuerAddress]
	if issuer == nil || !issuer.Active {
		panic("caller is not an approved issuer")
	}
	if id == "" {
		panic("credential ID is required")
	}
	if holder == address("") {
		panic("holder address is required")
	}
	if !isValidSHA256Hex(documentHash) {
		panic("document hash must be 64 lowercase hexadecimal characters")
	}
	if credentials[id] != nil {
		panic("credential ID already exists")
	}
	now := time.Now().Unix()
	if expiresAt != 0 && expiresAt <= now {
		panic("expiry must be in the future or zero for no expiry")
	}

	credentials[id] = &Credential{
		ID:           id,
		Issuer:       issuerAddress,
		Holder:       holder,
		DocumentHash: documentHash,
		IssuedAt:     now,
		ExpiresAt:    expiresAt,
		Revoked:      false,
	}
}

// RevokeCredential can only be called by the organisation that issued it.
func RevokeCredential(cur realm, id string) {
	requireCurrent(cur)
	caller := cur.Previous().Address()
	credential := credentials[id]
	if credential == nil {
		panic("credential not found")
	}
	if credential.Issuer != caller {
		panic("only the issuing organisation can revoke this credential")
	}
	if credential.Revoked {
		panic("credential already revoked")
	}
	credential.Revoked = true
}

// GetCredential returns a copy of the public verification record.
func GetCredential(id string) Credential {
	credential := credentials[id]
	if credential == nil {
		panic("credential not found")
	}
	return *credential
}

// IsCredentialValid reports whether a credential exists, has not been
// revoked, and has not expired. It does not validate the off-chain document.
func IsCredentialValid(id string) bool {
	credential := credentials[id]
	if credential == nil || credential.Revoked {
		return false
	}
	if credential.ExpiresAt != 0 && time.Now().Unix() >= credential.ExpiresAt {
		return false
	}
	return true
}

// GetIssuer returns the public issuer record.
func GetIssuer(issuerAddress address) Issuer {
	issuer := issuers[issuerAddress]
	if issuer == nil {
		panic("issuer not found")
	}
	return *issuer
}

// IsApprovedIssuer reports whether an address is currently authorised to issue.
func IsApprovedIssuer(issuerAddress address) bool {
	issuer := issuers[issuerAddress]
	return issuer != nil && issuer.Active
}

// isValidSHA256Hex validates a lowercase SHA-256 hex digest.
func isValidSHA256Hex(value string) bool {
	if len(value) != 64 {
		return false
	}
	for i := 0; i < len(value); i++ {
		ch := value[i]
		if !((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f')) {
			return false
		}
	}
	return true
}

// Render provides a minimal realm landing page.
func Render(path string) string {
	return "# Credora credential registry\n\nExperimental Gno realm. See the [project repository](https://github.com/Kenpachi-2/Credora) for development status and security notes.\n"
}
