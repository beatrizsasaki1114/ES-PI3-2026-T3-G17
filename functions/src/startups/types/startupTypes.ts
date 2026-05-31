//Sofia de Sousa

import { FieldValue, Timestamp } from "firebase-admin/firestore";

export type StartupStage =
    | "Nova"
    | "Expansao"
    | "Operacao";

export interface Fundador {
    Nome: string;
    Funcao: string;
    Porcentagem: number;
    DescricaoCurta: string;
}


export interface MembroExterno {
    Nome: string;
    Funcao: string;
    Porcentagem: number;
}

export interface DocumentoPublico {
    Tipo: string;
    Titulo: string;
    URL: string;
}

export interface StartupDocument {
    ID: string; 
    NomeStartup: string;
    Estagio: StartupStage;
    DescricaoCurta: string;
    DescricaoLonga: string;
    SumarioExecutivo: string;
    CapitalCaptadoCent: number;
    TotalTokensEmitidos: number;
    PrecoAtualToken: number;
    PrecoAnteriorToken?: number | null;
    DemoVideo: string;
    Fundadores: Fundador[];
    MembrosExterno: MembroExterno[];
    DocumentosPublicos: DocumentoPublico[];
    VisibilidadeDaPergunta: string;
    tags?: string[];
    createdAt?: Timestamp | FieldValue;
    updatedAt?: Timestamp | FieldValue;
    Perguntas?: String[];
    Respostas?: String[];
    Eventos?: Record<string, any[]>;
}

export interface StartupListItem {
    ID: string; 
    NomeStartup: string;
    Estagio: StartupStage;
    DescricaoCurta: string;
    CapitalCaptadoCent: number;
    TotalTokensEmitidos: number;
    PrecoAtualToken: number;
    tags?: string[];
}