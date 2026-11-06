export function parseCredentialValidityResult(payload: unknown): boolean {
  if (!payload || typeof payload !== "object") {
    throw new Error("The registry returned an invalid query result.");
  }

  const results = (payload as { results?: unknown }).results;
  if (!Array.isArray(results) || results.length === 0) {
    throw new Error("The registry returned no credential result.");
  }

  const first = results[0];
  const value = first && typeof first === "object"
    ? (first as { V?: { value?: unknown } }).V?.value
    : undefined;

  if (typeof value !== "boolean") {
    throw new Error("The registry returned an unrecognised credential result.");
  }

  return value;
}
