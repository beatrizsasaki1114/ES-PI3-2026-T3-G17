//Sofia de Sousa

//Função para normalizar strings, garantindo que sejam do tipo string e removendo espaços em branco extras
export function normalizeString(value: any): string {
    if (typeof value !== "string") return "";

    return value.trim();
}