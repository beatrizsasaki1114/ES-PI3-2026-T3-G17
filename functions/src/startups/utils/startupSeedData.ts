//Sofia de Sousa e Bruno Machado

//Backup das startups de demonstração para popular o banco de dados com informações reais e completas, facilitando os testes e a visualização das funcionalidades da plataforma.
import { StartupDocument } from "../types/startupTypes";

export const demoStartup: StartupDocument[] = [
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

        DemoVideo: "https://youtu.be/FzS2cYpV_e8",

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
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FEduFlow_Pitch.pdf?alt=media&token=9968723e-a694-4f50-973a-09ec5d100b54"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio EduFlow",
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FEduFlow_Plano_de_Negocios.pdf?alt=media&token=7a562836-2c8e-463f-a60d-a6bb06d30c62"
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
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FFinFlow_Pitch.pdf?alt=media&token=19232fb2-6b00-46ba-b8e5-f2315588d686"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio FinFlow",
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FFinFlow_Plano_de_Negocios.pdf?alt=media&token=b1d42bc1-7bbd-4179-9532-0bee26c30c88"
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

        DemoVideo: "https://www.youtube.com/watch?v=Wcud4sJzcZo",

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
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FAgroSmart_Pitch.pdf?alt=media&token=8c8b4532-b60b-4ad1-900d-6a44fc69ad21"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio AgroSmart",
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FAgroSmart_Plano_de_Negocios.pdf?alt=media&token=64c2a762-26a7-4a8e-903c-a532c7fc8a47"
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

        DemoVideo: "https://youtu.be/WfUmpk_V3go",

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
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FEcoTech_Pitch.pdf?alt=media&token=4ccaf531-5a45-426a-a893-d8685aef1a8e"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio EcoTech",
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FEcoTech_Plano_de_Negocios.pdf?alt=media&token=b4ac9cb3-03fb-4d47-af84-3386ff4da845"
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

        DemoVideo: "https://youtu.be/-S44gNxIXEY",

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
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FHealthSync_Pitch.pdf?alt=media&token=0dad8419-43e5-4cdc-8a0c-7df4d7d1b2bb"
            },
            {
                Tipo: "PDF",
                Titulo: "Plano de Negocio HealthSync",
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FHealthSync_Plano_de_Negocios.pdf?alt=media&token=281dac14-7e69-4c1c-9124-eb19ac2640a4"
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
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FLoginChain_Pitch.pdf?alt=media&token=732693fa-9e64-4dfd-8c34-14b7dfecdf62"
            },
            {
                Tipo: "PDF",
                Titulo: "LoginChain Plano de Negocio",
                URL: "https://firebasestorage.googleapis.com/v0/b/mesclainvest-db416.firebasestorage.app/o/documentos_startup%2FLoginChain_Plano_de_Negocios.pdf?alt=media&token=b1057c10-1c45-4f00-a07c-6f1b79c0811a"
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