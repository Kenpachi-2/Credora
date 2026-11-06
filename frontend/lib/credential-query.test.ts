import { describe, expect, it } from "vitest";
import { parseCredentialValidityResult } from "./credential-query";

describe("parseCredentialValidityResult", () => {
  it("accepts a valid credential result", () => {
    expect(parseCredentialValidityResult({ results: [{ V: { value: true } }] })).toBe(true);
  });

  it("preserves an invalid credential result", () => {
    expect(parseCredentialValidityResult({ results: [{ V: { value: false } }] })).toBe(false);
  });

  it("rejects an empty result list", () => {
    expect(() => parseCredentialValidityResult({ results: [] })).toThrow("no credential result");
  });

  it("rejects malformed values instead of coercing them", () => {
    expect(() => parseCredentialValidityResult({ results: [{ V: { value: "true" } }] })).toThrow("unrecognised");
  });

  it("rejects non-object payloads", () => {
    expect(() => parseCredentialValidityResult(null)).toThrow("invalid query result");
  });
});
