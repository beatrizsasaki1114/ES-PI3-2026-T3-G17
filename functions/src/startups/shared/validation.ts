export function normalizeString(value: any): string {
    if (typeof value !== "string") return "";

    return value.trim();
}