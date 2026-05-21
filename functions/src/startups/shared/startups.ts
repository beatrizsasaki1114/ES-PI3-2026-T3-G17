//Sofia de Sousa

import { StartupStage } from "../types/startupTypes";

export const allowedStages: StartupStage[] = [
    "Nova",
    "Operacao",
    "Expansao"
];

export function isValidStage(stage: string): boolean {
    return allowedStages.includes(stage as StartupStage);
}