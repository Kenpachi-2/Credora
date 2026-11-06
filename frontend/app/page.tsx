"use client";

import { useMemo, useState } from "react";

type Credential = {
  id: string;
  title: string;
  issuer: string;
  category: string;
  issued: string;
  expires: string;
  status: "Verified" | "Expiring soon" | "Pending";
  initials: string;
  tone: "violet" | "blue" | "amber" | "mint";
};

const initialCredentials: Credential[] = [
  { id: "CR-2025-00841", title: "Bachelor of Computer Science", issuer: "University of Bristol", category: "Degree", issued: "18 Jun 2024", expires: "No expiry", status: "Verified", initials: "UB", tone: "violet" },
  { id: "CR-2025-00712", title: "AWS Solutions Architect", issuer: "Amazon Web Services", category: "Certification", issued: "02 Feb 2025", expires: "02 Feb 2028", status: "Verified", initials: "aws", tone: "blue" },
  { id: "CR-2025-00609", title: "Professional Scrum Master I", issuer: "Scrum.org", category: "Certification", issued: "14 Sep 2023", expires: "14 Sep 2026", status: "Expiring soon", initials: "S", tone: "amber" },
  { id: "CR-2025-00438", title: "Data Protection Essentials", issuer: "OpenLearn Academy", category: "Course", issued: "09 Jan 2025", expires: "No expiry", status: "Verified", initials: "OA", tone: "mint" }
];

const navItems = [
  { label: "Overview", icon: "◫" },
  { label: "My credentials", icon: "▤" },
  { label: "Share & verify", icon: "⌁" },
  { label: "Issuers", icon: "▧" }
];

function Icon({ children }: { children: React.ReactNode }) {
  return <span className="icon" aria-hidden="true">{children}</span>;
}

export default function Home() {
  const [activeNav, setActiveNav] = useState("Overview");
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState("All");
  const [credentials, setCredentials] = useState(initialCredentials);
  const [showAdd, setShowAdd] = useState(false);
  const [showShare, setShowShare] = useState(false);
  const [newTitle, setNewTitle] = useState("");
  const [newIssuer, setNewIssuer] = useState("");
  const [toast, setToast] = useState("");

  const visibleCredentials = useMemo(() => credentials.filter((credential) => {
    const matchesQuery = [credential.title, credential.issuer, credential.id].join(" ").toLowerCase().includes(query.toLowerCase());
    const matchesFilter = filter === "All" || credential.status === filter;
    return matchesQuery && matchesFilter;
  }), [credentials, filter, query]);

  function addDemoCredential(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!newTitle.trim() || !newIssuer.trim()) return;
    setCredentials((current) => [{
      id: `DEMO-${Date.now().toString().slice(-6)}`,
      title: newTitle.trim(),
      issuer: newIssuer.trim(),
      category: "Other",
      issued: "Today",
      expires: "Not specified",
      status: "Pending",
      initials: newIssuer.trim().slice(0, 2).toUpperCase(),
      tone: "violet"
    }, ...current]);
    setNewTitle("");
    setNewIssuer("");
    setShowAdd(false);
    setToast("Demo credential added locally");
    window.setTimeout(() => setToast(""), 2600);
  }

  function copyDemoLink() {
    const link = "https://credora.example/verify/CR-2025-00841";
    if (navigator.clipboard?.writeText) {
      void navigator.clipboard.writeText(link).then(() => setToast("Demo verification link copied")).catch(() => setToast(link));
    } else {
      setToast(link);
    }
    window.setTimeout(() => setToast(""), 3200);
  }

  return (
    <main className="app-shell">
      <aside className="sidebar">
        <a className="brand" href="#" onClick={() => setActiveNav("Overview")}>
          <span className="brand-mark">c<span>.</span></span>
          <span className="brand-name">credora</span>
        </a>
        <div className="workspace-label">WORKSPACE</div>
        <nav className="side-nav" aria-label="Main navigation">
          {navItems.map((item) => (
            <button key={item.label} className={`nav-item ${activeNav === item.label ? "active" : ""}`} onClick={() => setActiveNav(item.label)}>
              <Icon>{item.icon}</Icon><span>{item.label}</span>
              {item.label === "My credentials" && <span className="nav-count">{credentials.length}</span>}
            </button>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <div className="help-card">
            <div className="help-icon">✳</div>
            <strong>Your credentials. Your call.</strong>
            <p>You decide what to share, and when.</p>
            <button onClick={() => setShowShare(true)}>How sharing works <span>↗</span></button>
          </div>
          <button className="profile-row" onClick={() => setToast("Wallet profile is a visual demo for now")}>
            <span className="avatar">JD</span>
            <span className="profile-copy"><strong>Jordan Davis</strong><small>Personal account</small></span>
            <span className="profile-more">···</span>
          </button>
        </div>
      </aside>

      <section className="main-panel">
        <header className="topbar">
          <div className="breadcrumb">Workspace <span>/</span> <strong>{activeNav}</strong></div>
          <div className="topbar-actions">
            <span className="network-pill"><span className="network-dot" /> Onyx testnet</span>
            <button className="wallet-button" onClick={() => setToast("Wallet connection is not wired up yet")}>
              <span className="wallet-symbol">◇</span> Connect wallet
            </button>
            <button className="icon-button" aria-label="Notifications" onClick={() => setToast("You're all caught up")}>♧</button>
          </div>
        </header>

        <div className="content">
          {activeNav === "Overview" ? (
            <>
              <div className="welcome-row">
                <div>
                  <div className="eyebrow">YOUR PROFESSIONAL IDENTITY</div>
                  <h1>Your achievements,<br className="mobile-break" /> all in one place.</h1>
                  <p className="subtitle">A trusted home for everything you’ve worked hard to earn.</p>
                </div>
                <button className="primary-button" onClick={() => setShowAdd(true)}><span>＋</span> Add a credential</button>
              </div>

              <div className="stats-grid">
                <div className="stat-card"><div className="stat-top"><span>Total credentials</span><span className="stat-icon purple">▤</span></div><div className="stat-value">{credentials.length.toString().padStart(2, "0")}</div><div className="stat-foot">Your growing collection</div></div>
                <div className="stat-card"><div className="stat-top"><span>Verified</span><span className="stat-icon green">✓</span></div><div className="stat-value">{credentials.filter((c) => c.status === "Verified").length.toString().padStart(2, "0")}</div><div className="stat-foot"><span className="green-text">●</span> Confirmed on the registry*</div></div>
                <div className="stat-card"><div className="stat-top"><span>Shared this month</span><span className="stat-icon blue">↗</span></div><div className="stat-value">03</div><div className="stat-foot">Across 2 organisations</div></div>
              </div>

              <section className="credentials-section">
                <div className="section-heading">
                  <div><div className="eyebrow">YOUR COLLECTION</div><h2>Recent credentials</h2></div>
                  <button className="text-button" onClick={() => setActiveNav("My credentials")}>View all <span>→</span></button>
                </div>
                <div className="toolbar">
                  <div className="search-box"><span>⌕</span><input aria-label="Search credentials" placeholder="Search credentials or issuers..." value={query} onChange={(event) => setQuery(event.target.value)} /></div>
                  <select aria-label="Filter by status" value={filter} onChange={(event) => setFilter(event.target.value)}><option>All</option><option>Verified</option><option>Expiring soon</option><option>Pending</option></select>
                </div>
                <div className="credential-list">
                  {visibleCredentials.length === 0 ? <div className="empty-state">No credentials match your search.</div> : visibleCredentials.map((credential) => (
                    <article className="credential-row" key={credential.id}>
                      <div className={`issuer-logo ${credential.tone}`}>{credential.initials}</div>
                      <div className="credential-main"><strong>{credential.title}</strong><span>{credential.issuer}</span></div>
                      <div className="credential-category">{credential.category}</div>
                      <div className="credential-date"><span>ISSUED</span><strong>{credential.issued}</strong></div>
                      <div className="credential-status"><span className={`status-dot ${credential.status === "Verified" ? "verified" : credential.status === "Pending" ? "pending" : "soon"}`} />{credential.status}</div>
                      <button className="row-menu" aria-label={`More about ${credential.title}`} onClick={() => setToast(`Credential ID: ${credential.id}`)}>···</button>
                    </article>
                  ))}
                </div>
                <div className="list-foot"><span>Showing {visibleCredentials.length} of {credentials.length} credentials</span><span>＊ Sample dashboard data</span></div>
              </section>

              <div className="bottom-grid">
                <section className="share-card">
                  <div className="share-art"><div className="share-orbit orbit-one" /><div className="share-orbit orbit-two" /><div className="share-doc"><span>✓</span><i /><i /><i /></div><div className="share-spark">✦</div></div>
                  <div className="share-copy"><div className="eyebrow">SHARE WITH CONFIDENCE</div><h3>One link. Real proof.</h3><p>Let anyone verify a credential without chasing paperwork.</p><button className="dark-button" onClick={() => setShowShare(true)}>Create a share link <span>→</span></button></div>
                </section>
                <section className="activity-card">
                  <div className="section-heading compact"><div><div className="eyebrow">STAY IN THE LOOP</div><h3>Recent activity</h3></div><button className="dots-button" onClick={() => setToast("Activity menu")}>···</button></div>
                  <div className="activity-item"><span className="activity-icon purple">＋</span><div><strong>Credential added</strong><p>Bachelor of Computer Science</p><small>18 Jun 2024</small></div></div>
                  <div className="activity-item"><span className="activity-icon green">✓</span><div><strong>Verification completed</strong><p>AWS Solutions Architect</p><small>02 Feb 2025</small></div></div>
                </section>
              </div>
              <p className="disclaimer">* This is a UI prototype. The sample records and verification states are illustrative, not live blockchain data.</p>
            </>
          ) : activeNav === "My credentials" ? (
            <>
              <div className="welcome-row"><div><div className="eyebrow">YOUR COLLECTION</div><h1>My credentials.</h1><p className="subtitle">Manage your qualifications and certificates.</p></div><button className="primary-button" onClick={() => setShowAdd(true)}>＋ Add a credential</button></div>
              <div className="toolbar standalone"><div className="search-box"><span>⌕</span><input placeholder="Search credentials or issuers..." value={query} onChange={(event) => setQuery(event.target.value)} /></div><select value={filter} onChange={(event) => setFilter(event.target.value)}><option>All</option><option>Verified</option><option>Expiring soon</option><option>Pending</option></select></div>
              <div className="credential-list full-list">{visibleCredentials.map((c) => <article className="credential-row" key={c.id}><div className={`issuer-logo ${c.tone}`}>{c.initials}</div><div className="credential-main"><strong>{c.title}</strong><span>{c.issuer}</span></div><div className="credential-category">{c.category}</div><div className="credential-date"><span>ISSUED</span><strong>{c.issued}</strong></div><div className="credential-status"><span className={`status-dot ${c.status === "Verified" ? "verified" : "soon"}`} />{c.status}</div><button className="row-menu" onClick={() => setToast(`Credential ID: ${c.id}`)}>···</button></article>)}</div>
              <p className="disclaimer">Demo data only. Live credential retrieval will be connected to Gno in a later milestone.</p>
            </>
          ) : activeNav === "Share & verify" ? (
            <>
              <div className="eyebrow">PORTABLE PROOF</div><h1>Share & verify.</h1><p className="subtitle">Give employers a simple way to check your achievements.</p>
              <div className="feature-panel"><div className="feature-symbol">↗</div><h2>Share only what matters.</h2><p>Choose a credential, create a time-limited presentation, and send a verification link. The holder-controlled sharing flow is planned; this preview uses a sample link.</p><button className="primary-button" onClick={copyDemoLink}>Copy sample verification link</button></div>
              <div className="feature-panel secondary"><div className="eyebrow">FOR VERIFIERS</div><h2>Check a credential</h2><p>In the production app, a verifier will check the issuer, document digest, expiry, and revocation status against the Gno registry.</p><button className="outline-button" onClick={() => setToast("Public verification page is coming in the next milestone")}>Open verification preview ↗</button></div>
            </>
          ) : (
            <>
              <div className="eyebrow">TRUSTED SOURCES</div><h1>Issuers.</h1><p className="subtitle">Organisations authorised to issue credentials.</p>
              <div className="feature-panel"><div className="feature-symbol">▧</div><h2>Issuer directory is coming soon.</h2><p>Approved universities, certification bodies, and training providers will be discoverable here. Issuer approval will be governed by the on-chain registry and an accountable review process.</p><button className="outline-button" onClick={() => setToast("Issuer onboarding will be available in a future release")}>Learn about issuer onboarding ↗</button></div>
            </>
          )}
        </div>
      </section>

      {showAdd && <div className="modal-backdrop" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget) setShowAdd(false); }}><section className="modal" role="dialog" aria-modal="true" aria-labelledby="add-title"><button className="modal-close" onClick={() => setShowAdd(false)} aria-label="Close">×</button><div className="eyebrow">GROW YOUR COLLECTION</div><h2 id="add-title">Add a credential</h2><p>This creates a local demo entry only. Issuer-backed issuance will be connected later.</p><form onSubmit={addDemoCredential}><label>Credential name<input required value={newTitle} onChange={(e) => setNewTitle(e.target.value)} placeholder="e.g. MSc Data Science" /></label><label>Issuing organisation<input required value={newIssuer} onChange={(e) => setNewIssuer(e.target.value)} placeholder="e.g. University of Leeds" /></label><div className="modal-actions"><button type="button" className="outline-button" onClick={() => setShowAdd(false)}>Cancel</button><button className="primary-button" type="submit">Add demo credential</button></div></form></section></div>}
      {showShare && <div className="modal-backdrop" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget) setShowShare(false); }}><section className="modal" role="dialog" aria-modal="true" aria-labelledby="share-title"><button className="modal-close" onClick={() => setShowShare(false)} aria-label="Close">×</button><div className="eyebrow">PRIVATE BY DESIGN</div><h2 id="share-title">You’re in control.</h2><p>Credora is being designed so you choose which credential details to present. The original document stays off-chain; the Gno registry stores a minimal verification record.</p><div className="privacy-points"><div><span>01</span><strong>Choose a credential</strong><small>Select the qualification you want to prove.</small></div><div><span>02</span><strong>Share a presentation</strong><small>Give a verifier only the information needed.</small></div><div><span>03</span><strong>Verify its status</strong><small>Check issuer authorisation and revocation on Gno.</small></div></div><button className="primary-button modal-full" onClick={() => { setShowShare(false); setActiveNav("Share & verify"); }}>Got it</button></section></div>}
      {toast && <div className="toast" role="status">{toast}</div>}
    </main>
  );
}
