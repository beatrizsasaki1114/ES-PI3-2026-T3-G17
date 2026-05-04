
// Sofia de Sousa - Lembrar de voltar para comentar dps 

import {FieldValue } from "firebase-admin/firestore";
import {
    StartupDocument,
    StartupListItem
} from "../types/startupTypes";

import {db} from "../../shared/firebase";


const startupsCollection = db.collection("startups");
const demoStartup: StartupDocument[] = [
    {
        ID: "1",
        NomeStartup: "EduFlow",
        Estagio: "Expansao",

        DescricaoCurta: "Especialista em educação digital",

        DescricaoLonga:
            "EduFlow é uma plataforma educacional baseada em inteligência artificial que adapta o conteúdo ao ritmo e estilo de aprendizado de cada aluno.",

        SumarioExecutivo:
            "Plataforma educacional que personaliza o aprendizado com base no desempenho do aluno",

        CapitalCaptadoCent: 6000000,
        TotalTokensEmitidos: 400000,
        PrecoAtualToken: 0.9,

        DemoVideo: "https://demo.eduflow.com",

        Fundadores: [
            {
                Nome: "Pedro Alves",
                Funcao: "CEO",
                Porcentagem: 60,
                DescricaoCurta: "Especialista em educação digital"
            },
            {
                Nome: "Marcos Vinicius",
                Funcao: "CTO",
                Porcentagem: 30,
                DescricaoCurta: "Educador"
            }
        ],

        MembrosExterno: [
            {
                Nome: "Eduardo Souza",
                Funcao: "Investidor",
                Porcentagem: 10
            }
        ],

        DocumentosPublicos: [
            {
                Tipo: "PDF",
                Titulo: "Pitch EduFlow",
                URL: "https://docs.eduflow.com/eduflow_pitch.pdf"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio EduFlow",
                URL: "https://docs.eduflow.com/eduflow_plano.pdf"
            }
        ],

        VisibilidadeDaPergunta: "Publica",

        tags: [
            "educação",
            "tecnologia",
            "inteligência artificial"
        ]
    },

    {
        ID: "2",
        NomeStartup: "FinFlow",
        Estagio: "Nova",

        DescricaoCurta: "Gestão financeira para PMEs",

        DescricaoLonga:
            "FinFlow é uma plataforma financeira completa para pequenas e médias empresas com automação e IA.",

        SumarioExecutivo:
            "Software que automatiza fluxo de caixa, emissão de notas e relatórios financeiros.",

        CapitalCaptadoCent: 300000000,
        TotalTokensEmitidos: 1200000,
        PrecoAtualToken: 3.1,

        DemoVideo: "https://demo.finflow.com",

        Fundadores: [
            {
                Nome: "Mariana Costa",
                Funcao: "CEO",
                Porcentagem: 65,
                DescricaoCurta: "Especialista em fintech"
            },
            {
                Nome: "Gustavo Pereira",
                Funcao: "CTO",
                Porcentagem: 30,
                DescricaoCurta: "Engenheiro de dados"
            }
        ],

        MembrosExterno: [
            {
                Nome: "Filipa Landim",
                Funcao: "Investidor",
                Porcentagem: 20
            }
        ],

        DocumentosPublicos: [
            {
                Tipo: "PDF",
                Titulo: "Pitch FinFlow",
                URL: "https://docs.finflow.com/finflow_pitch.pdf"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio FinFlow",
                URL: "https://docs.finflow.com/finflow_plano.pdf"
            }
        ],

        VisibilidadeDaPergunta: "Publica",

        tags: [
            "fintech",
            "gestão financeira",
            "pme"
        ]
    },

    {
        ID: "3",
        NomeStartup: "AgroSmart",
        Estagio: "Expansao",

        DescricaoCurta: "Automação agrícola com IoT",

        DescricaoLonga:
            "AgroSmart oferece solução para agricultura de precisão com sensores IoT, satélites e IA.",

        SumarioExecutivo:
            "Plataforma que usa sensores e IA para otimizar produtividade agrícola.",

        CapitalCaptadoCent: 150000000,
        TotalTokensEmitidos: 750000,
        PrecoAtualToken: 1.8,

        DemoVideo: "https://demo.agrosmart.com",

        Fundadores: [
            {
                Nome: "Lucas Ribeiro",
                Funcao: "CEO",
                Porcentagem: 45,
                DescricaoCurta: "Engenheiro agrônomo"
            },
            {
                Nome: "Beatriz Rocha",
                Funcao: "CTO",
                Porcentagem: 30,
                DescricaoCurta: "Engenheira agrônoma"
            }
        ],

        MembrosExterno: [
            {
                Nome: "Vitor Mendes",
                Funcao: "Investidor",
                Porcentagem: 25
            }
        ],

        DocumentosPublicos: [
            {
                Tipo: "PDF",
                Titulo: "Pitch AgroSmart",
                URL: "https://docs.agrosmart.com/agrosmart_pitch.pdf"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio AgroSmart",
                URL: "https://docs.agrosmart.com/agrosmart_plano.pdf"
            }
        ],

        VisibilidadeDaPergunta: "Publica",

        tags: [
            "agrotech",
            "iot",
            "agricultura de precisão"
        ]
    },

    {
        ID: "4",
        NomeStartup: "EcoTech",
        Estagio: "Operacao",

        DescricaoCurta: "Monitoramento ambiental para empresas",

        DescricaoLonga:
            "Plataforma completa de monitoramento ambiental voltada para indicadores ESG em tempo real.",

        SumarioExecutivo:
            "A EcoTech é uma plataforma de monitoramento ESG em tempo real.",

        CapitalCaptadoCent: 250000000,
        TotalTokensEmitidos: 1000000,
        PrecoAtualToken: 2.5,

        DemoVideo: "",

        Fundadores: [
            {
                Nome: "Ana Silva",
                Funcao: "CEO",
                Porcentagem: 50,
                DescricaoCurta: "Especialista em Sustentabilidade"
            },
            {
                Nome: "Carlos Souza",
                Funcao: "CTO",
                Porcentagem: 40,
                DescricaoCurta: "Engenheiro Ambiental"
            }
        ],

        MembrosExterno: [
            {
                Nome: "João Lucas",
                Funcao: "Advisor",
                Porcentagem: 10
            }
        ],

        DocumentosPublicos: [
            {
                Tipo: "PDF",
                Titulo: "Pitch EcoTech",
                URL: "https://docs.ecotech.com/ecotech_pitch.pdf"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio EcoTech",
                URL: "https://docs.ecotech.com/ecotech_plano.pdf"
            }
        ],

        VisibilidadeDaPergunta: "Publica",

        tags: [
            "sustentabilidade",
            "monitoramento ambiental",
            "esg"
        ]
    },

    {
        ID: "5",
        NomeStartup: "HealthSync",
        Estagio: "Nova",

        DescricaoCurta: "Integração de dados médicos",

        DescricaoLonga:
            "O HealthSync centraliza e integra dados médicos em um ambiente seguro.",

        SumarioExecutivo:
            "Plataforma que centraliza dados médicos.",

        CapitalCaptadoCent: 120000000,
        TotalTokensEmitidos: 800000,
        PrecoAtualToken: 1.8,

        DemoVideo: "",

        Fundadores: [
            {
                Nome: "Mariana Costa",
                Funcao: "CEO",
                Porcentagem: 50,
                DescricaoCurta: "Médica e empreendedora"
            },
            {
                Nome: "Marcelo Campos",
                Funcao: "CTO",
                Porcentagem: 45,
                DescricaoCurta: "Médico"
            }
        ],

        MembrosExterno: [
            {
                Nome: "Dr. Paulo",
                Funcao: "Consultor",
                Porcentagem: 5
            }
        ],

        DocumentosPublicos: [
            {
                Tipo: "PDF",
                Titulo: "Pitch HealthSync",
                URL: "https://docs.healthsync.com/healthsync_pitch.pdf"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio HealthSync",
                URL: "https://docs.healthsync.com/healthsync_plano.pdf"
            }
        ],

        VisibilidadeDaPergunta: "Privada",

        tags: [
            "healthtech",
            "dados médicos",
            "integração de saúde"
        ]
    },

    {
        ID: "6",
        NomeStartup: "LoginChain",
        Estagio: "Expansao",

        DescricaoCurta: "Rastreabilidade logística com blockchain",

        DescricaoLonga:
            "LoginChain garante transparência e rastreabilidade em cadeias logísticas.",

        SumarioExecutivo:
            "Plataforma que garante transparência e rastreabilidade em cadeias logísticas.",

        CapitalCaptadoCent: 110000000,
        TotalTokensEmitidos: 650000,
        PrecoAtualToken: 1.7,

        DemoVideo: "https://demo.loginchain.com",

        Fundadores: [
            {
                Nome: "Rafael Nunes",
                Funcao: "CEO",
                Porcentagem: 50,
                DescricaoCurta: "Especialista em blockchain"
            },
            {
                Nome: "Camila Duarte",
                Funcao: "CTO",
                Porcentagem: 30,
                DescricaoCurta: "Especialista em blockchain"
            }
        ],

        MembrosExterno: [
            {
                Nome: "Laís Mendonça",
                Funcao: "Investidor",
                Porcentagem: 20
            }
        ],

        DocumentosPublicos: [
            {
                Tipo: "PDF",
                Titulo: "LoginChain Pitch",
                URL: "https://docs.loginchain.com/loginchain_pitch.pdf"
            },
            {
                Tipo: "PDF",
                Titulo: "LoginChain Plano de Negocio",
                URL: "https://docs.loginchain.com/loginchain_plano.pdf"
            }
        ],

        VisibilidadeDaPergunta: "Privada",

        tags: [
            "blockchain",
            "rastreabilidade",
            "logística"
        ]
    }

];

function toListItem(
    id: string,
    startup: StartupDocument
): StartupListItem {
    return {
        ID: id,
        NomeStartup: startup.NomeStartup,
        Estagio: startup.Estagio,
        DescricaoCurta: startup.DescricaoCurta,
        CapitalCaptadoCent: startup.CapitalCaptadoCent,
        TotalTokensEmitidos: startup.TotalTokensEmitidos,
        PrecoAtualToken: startup.PrecoAtualToken,
        tags: startup.tags
    };
}

export async function listStartupItems(): Promise<StartupListItem[]> {
    const snapshot = await startupsCollection
        .limit(100)
        .get();

    return snapshot.docs.map((doc) =>
        toListItem(
            doc.id,
            doc.data() as StartupDocument
        )
    );
}

export async function getStartupById(
    startupId: string
): Promise<StartupDocument | undefined> {

    const startupSnapshot = await startupsCollection
        .doc(startupId)
        .get();

    if (!startupSnapshot.exists) {
        return undefined;
    }

    return startupSnapshot.data() as StartupDocument;
}

export async function userIsInvestor(
    startupId: string,
    uid: string
): Promise<boolean> {

    const investorSnapshot = await startupsCollection
        .doc(startupId)
        .collection("investidores")
        .doc(uid)
        .get();

    return investorSnapshot.exists;
}

export async function seedDemoStartups(): Promise<string[]> {

    const batch = db.batch();

    for (const startup of demoStartup) {

        const { ID, ...data } = startup as StartupDocument & { ID: string };

        const startupRef = startupsCollection.doc(ID);
     
        batch.set(
            startupRef,
            {
                NomeStartup: data.NomeStartup,
                Estagio: data.Estagio,
                DescricaoCurta: data.DescricaoCurta,
                DescricaoLonga: data.DescricaoLonga,
                SumarioExecutivo: data.SumarioExecutivo,
                CapitalCaptadoCent: data.CapitalCaptadoCent,
                TotalTokensEmitidos: data.TotalTokensEmitidos,
                PrecoAtualToken: data.PrecoAtualToken,
                DemoVideo: data.DemoVideo,
                Fundadores: data.Fundadores,
                MembrosExterno: data.MembrosExterno,
                DocumentosPublicos: data.DocumentosPublicos,
                VisibilidadeDaPergunta: data.VisibilidadeDaPergunta,
                tags: data.tags,
                createdAt: FieldValue.serverTimestamp(),
                updatedAt: FieldValue.serverTimestamp()
            },
            { merge: true }
        );
    }

    await batch.commit();
  
    return demoStartup.map((startup) => startup.ID);
}