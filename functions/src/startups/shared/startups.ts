//Sofia de Sousa

import { StartupStage } from "../types/startupTypes";

//A variável só pode contar os valores definidos no tipo StartupStage, garantindo que o estágio da startup seja sempre válido e consistente em toda a aplicação.
export const allowedStages: StartupStage[] = [
    "Nova",
    "Operacao",
    "Expansao"
];

//Verifica se o estágio informado é válido
export function isValidStage(stage: string): boolean {
    return allowedStages.includes(stage as StartupStage);
}