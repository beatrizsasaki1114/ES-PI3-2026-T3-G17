//Criada por Sofia de Sousa

// DTO significa - objeto usado para transferir dados
// Nesse caso ele define o formato que se espera vindo do Flutter
// EX - {
    // "valor": 100
// }

export interface BalanceOperationDTO {
    valor: number;
}

//Formato da resposta da function
// Ajuda a padronizar o que o Flutter vai receber, facilitando o tratamento da resposta no app
export interface BalanceOperationResultDTO {
    success: boolean;
    message: string;
    saldoReais: number;
}