import { StartupStage } from "../types/startupTypes";

export const allowedStages: StartupStage[] = [
    "Nova",
    "Validacao",
    "Operecao",
    "Expansao"
];

export function isValidStage(stage: string): boolean {
    return allowedStages.includes(stage as StartupStage);
}