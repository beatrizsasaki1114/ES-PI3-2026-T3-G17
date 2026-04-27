// 1 - Cria uma função que pode ser chamada diretamente pelo Front (onCall)
//     HttpsError - Usado para retornar erros padronizados
// 2 - allowedStages - Lista de estágios permitidos para as startups (nova, operação, expansão)
// 3 - requireAuthenticatedUser - garante que o usuário está autenticado antes de acessar a função
// 4 - normalizeString - Limpa e normaliza a String (remove espaços por exemplo)
// 5 - listStartupItems - Busca os dados das startups (provavelmente do banco)
// 6 - StartupStage - Tipos dos estágios das startups

import {HttpsError, onCall} from "firebase-functions/https";
import {allowedStages} from "../shared/constants";
import {requireAuthenticatedUser} from "../shared/auth";
import {normalizeString} from "../shared/validation";
import {listStartupItems} from "../repositories/startupRepository";
import {StartupStage} from "../types";

// Criando a função
export const listStartups = onCall(async (request) => {
  // Se o usuário não estiver logado, a função retorna um erro
  requireAuthenticatedUser(request);

  // Stage - filtro por estágio da startup (nova, operação, expansão)
  // Search - filtro por termo de busca (nome, descrição, tags)
  const stage = normalizeString(request.data?.stage);

  // Normaliza a string e converte para minúscula
  const searchTerm = normalizeString(request.data?.search)
    ?.toLocaleLowerCase("pt-BR");

  // Se o usuário enviar um Stage inválido, a função retorna um erro,
  // evitando dados incorretos
  if (stage && !allowedStages.includes(stage as StartupStage)) {
    throw new HttpsError(
      "invalid-argument",
      "Filtro stage inválido. Use nova, operacao ou expansao"
    );
  }

  // Busca todas as startups e aplicar filtros
  const startups = (await listStartupItems())

    // Se não tiver STAGE, retorna todas as startups
    // Se tiver filtra pelos estágios
    .filter((startup) => !stage || startup.stage === stage)

    // Se não houver termo de busca retorna todas as startups
    .filter((startup) => {
    // Se não houver busca, retorna tudo
      if (!searchTerm) {
        return true;
      }

      // Junta vários campos da startup em uma string única para busca
      const searchable = [
        startup.name,
        startup.shortDescription,
        startup.stage,
        ...startup.tags,
      ]
        .join(" ")
        .toLocaleLowerCase("pt-BR");

      // Verifica se o termo está contido na string
      return searchable.includes(searchTerm);
    })

    // Ordena alfabeticamente pelo nome
    .sort((left, right) => left.name.localeCompare(right.name));

  return {
    // Quantidade de resultados encontrados
    count: startups.length,
    // Estado atual dos filtros aplicados
    // para o Front saber quais filtros estão ativos
    filters: {
      availableStages: allowedStages, // Lista de estágios possíveis
      stage: stage ?? null, // Filtro aplicado (ou null)
      search: searchTerm ?? null, // Termo de busca (ou null)
    },
    // Lista de startups
    data: startups,
  };
});
