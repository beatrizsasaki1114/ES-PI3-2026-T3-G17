
//Usado no FireStore para valores especiais como Timestamp ou FieldValue
import { FieldValue } from 'firebase-admin/firestore';


//Estágios de uma startup
export type StartupStage = 'nova' | 'operacao' | 'expansao';

//Defina se uma pergunta é
export type QuestionVisibility = 'publica' | 'privada';

//Representa o usuário logado
export type AuthenticatedUser = {
    uid: string;
    email?: string; //Opcional
};

//Dados  de um fundador 
export type Founder = {
    name: string;
    role: string;
    equiptyPercentage: number;
    bio?: string;
};

//Dados de um membro externo da startup
export type ExternalMember = {
    name: string;
    role: string;
    percentage: number;
    bio?: string;
};

//Dados dos documentos da startup
export type StartupDocument = {
    name: string;
    stage: StartupStage;
    shortDescription: string;
    description: string;
    executiveSummary: string;
    capitalRaisedCents: number;
    totalTokensPriceCents: number;
    founders: Founder[];
    externalMembers: ExternalMember[];
    demoVideos: string[];
    pitchDeckUrl?: string;
    coverImageUrl?: string;
    tags: string[];
    createdAt?: Timestamp;
    updatedAt?: Timestamp;
};

//Representa uma pergunta feita por um investidor sobre a startup
export type StartupQuestionDocument = {
    authorUid: string;
    authorEmail?: string;
    text: string;
    visibility: QuestionVisibility;
    answer?: string;
    asweredAt?: Timestamp;
    createdAt?: FieldValue;
};

//Lista de itens de dados que a startup possue
export type StartupListItem = {
    id: string;
    name: string;
    stage: StartupStage;
    shortDescription: string;
    capitalRaisedCents: number;
    totalTokensPriceCents: number;
    currentTokenPriceCents: number;
    coverImageUrl?: string;
    tags: string[];
};