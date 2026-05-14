// Feito por Heloisa
import { Timestamp } from 'firebase-admin/firestore';

// esqueleto/estrutura da pergunta
export type Question = {
    id?: string;
    autorId: string; 
    startupId: string; 
    pergunta: string;
    isPrivada: boolean; 
    dataCriacao: Timestamp;
    resposta?: string;
    respostaEnviada: boolean;
}



// anotações da aula
//ciclo de vida - método setstate
/*
2 - entender métodos assíncronos, definitivamente não pode ter dúvidas
3- pacotes de áudio (pacotes para trabalhar com áudio, audioplayer, recorder e outras classes importantes ligadas ao contexto do gravador de áudio, por exemplo, 
Duration)

import 'dart:async' isso é do pacote do >dart<

em apps modernos, o controle de permissões como acessar o microfone, câmera, arquivos está na mão do usuário.

'package': permission_handler é um pacote para permissões.
curiosidade: 
    pesquisar em kotlin como os aplicativos gerenciam permissões. buscar por: android handle permissions kotlin
*/