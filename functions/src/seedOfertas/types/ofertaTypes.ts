// Beatriz Naomi
import {Timestamp} from "firebase-admin/firestore";
export interface OfertaDocument {
  startupId: string;
  startupNome: string;
  precoUnitario: number;
  quantidadeTokens: number;
  valorTotal: number;
  status: "ativa" | "vendida";
  vendedorId: string;
  vendedorNome: string;
  compradorId?: string;
  dataCriacao: Timestamp;
  investmentDate: Timestamp;
  dataVenda?: Timestamp;
}