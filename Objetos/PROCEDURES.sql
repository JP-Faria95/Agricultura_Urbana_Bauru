/* PROCEDURE PD_GLOBAL_ENTIDADE_INSERT */

CREATE OR REPLACE PROCEDURE PD_GLOBAL_ENTIDADE_INSERT
(P_ID_ENTIDADE IN NUMBER, P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS
BEGIN

    /* POSSÍVEIS ENTIDADES CADASTRADAS NO PROJETO
    1 - AGRICULTORES
    2 - HORTAS URBANAS
    3 - FEIRAS MUNICIPAIS
    4 - ATRATIVOS TURÍSTICOS
    5 - SERVIÇOS PARA AGRICULTURA
    6 - INICIATIVAS PÚBLICAS
    7 - VIVÊNCIA RURAL
    */

    -- CHAMA A PROCEDURE DE ACORDO COM O ID_PARAMETRO
    CASE
        WHEN P_ID_ENTIDADE = 1 THEN PD_AGRICULTORES_INSERT(P_DADOS_ENTIDADES, P_ID_REGISTRO, P_ID_ENTIDADE, P_NOVO_CADASTRO, P_ID_REGISTRO_ATUAL);
        WHEN P_ID_ENTIDADE = 2 THEN PD_HORTAS_URBANAS_INSERT(P_DADOS_ENTIDADES, P_ID_REGISTRO, P_ID_ENTIDADE, P_NOVO_CADASTRO, P_ID_REGISTRO_ATUAL);
        WHEN P_ID_ENTIDADE = 3 THEN PD_FEIRAS_MUNICIPAIS_INSERT(P_DADOS_ENTIDADES, P_ID_REGISTRO, P_ID_ENTIDADE, P_NOVO_CADASTRO, P_ID_REGISTRO_ATUAL);
        WHEN P_ID_ENTIDADE = 4 THEN PD_ATRATIVOS_TURISTICOS_INSERT(P_DADOS_ENTIDADES, P_ID_REGISTRO, P_ID_ENTIDADE, P_NOVO_CADASTRO, P_ID_REGISTRO_ATUAL);
        WHEN P_ID_ENTIDADE = 5 THEN PD_SERVICOS_AGRICULTURA_INSERT(P_DADOS_ENTIDADES, P_ID_REGISTRO, P_ID_ENTIDADE, P_NOVO_CADASTRO, P_ID_REGISTRO_ATUAL);   
        WHEN P_ID_ENTIDADE = 6 THEN PD_INICIATIVAS_PUBLICAS_INSERT(P_DADOS_ENTIDADES, P_ID_REGISTRO, P_ID_ENTIDADE, P_NOVO_CADASTRO, P_ID_REGISTRO_ATUAL);
        ELSE
            RAISE_APPLICATION_ERROR(
                -20001,
                'TIPO DE ENTIDADE INVÁLIDO'
            );
    END CASE;
END PD_GLOBAL_ENTIDADE_INSERT;



/* PROCEDURE PD_AGRICULTORES_INSERT
-> RESPONSÁVEL POR CADASTRAR UM AGRICULTOR E OUTRAS TABELAS RELACIONADAS A ELES ...
-> RECEBE COMO PARAMETRO OS DADOS PREENCHIDOS NO FRONT-END PELO AGRICULTOR ...
-> FORMATO JSON: 
    {
        "agricultor": "João da Silva",
        "email": "joao@email.com",
        "telefone_1": 14999999999,
        "telefone_2": 14988888888,
        "descricao": "Agricultor especializado em hortaliças orgânicas.",
        "familiar": "S",
        "hectares_total": "5.50",
        "hectares_plantio": "3.20",
        "comercio": "S",
        "caf": "SP123456789",
        "vivencia_rural": "S",
        "localizacao": {
            "endereco": "",
            "bairro": "",
            "distrito": "",
            "cep": "",
            "latitude": "",
            "longitude": "",
            "id_zona": "",
            "municipio": "",
            "uf": ""   
        },
        "atividades": [
            {
                "id_atividade": 1
            },
            {
                "id_atividade": 3
            }
        ],
        "certificacoes": [
            {
                "id_certificacao": 2,
                "dt_certificado": "15-01-2026",
                "dt_vencimento": "2027-01-15",
                "certificado_base64": null
            },
            {
                "id_certificacao": 5,
                "dt_certificado": "20-03-2027",
                "dt_vencimento": null,
                "certificado_base64": null
            }
        ],
        "organizacoes": [
            {
                "id_organizacao": 4
            },
            {
                "id_organizacao": 7
            }
        ],
        "pontos_venda": [
            {
                "id_ponto": 10
            },
            {
                "id_ponto": 12
            }
        ],
        "qualificacoes": [
            {
                "qualificacao": "Curso de Agricultura Orgânica",
                "dt_qualificacao": "2025-08-10",
                "id_tipo_qualificacao": 1,
                "certificado_base64": null
            },
            {
                "qualificacao": "Manejo Sustentável do Solo",
                "dt_qualificacao": "2026-02-05",
                "id_tipo_qualificacao": 2,
                "certificado_base64": null
            }
        ],
        "redes_sociais": [
            {
                "url_rede": "",
                "id_tipo_rede": ""
            },
            {
                "url_rede": "",
                "id_tipo_rede": ""
            }
        ],
        "subcategorias": [
            {
                "id_subcategoria": 3
            },
            {
                "id_subcategoria": 6
            }
        ],
        "dados_vivencia_rural": {
            "acessibilidade_pcd": "S",
            "estacionamento": "Estacionamento disponível para carros e ônibus de excursão.",
            "descricao": "Experiência de turismo rural com visita guiada à propriedade, contato com a natureza e atividades educativas sobre agricultura sustentável.",
            "funcionamento": "Sábados e domingos, das 08h às 17h",
            "atividades": [
                {
                    "id_atividade": 1
                },
                {
                    "id_atividade": 3
                }
            ],
            "qualificacoes": [
                {
                    "qualificacao": "Turismo rural sustentável",
                    "dt_qualificacao": "10/08/2025",
                    "id_tipo_qualificacao": 1,
                    "certificado_base64": null
                },
                {
                    "qualificacao": "Educação ambiental",
                    "dt_qualificacao": "05/02/2026",
                    "id_tipo_qualificacao": 2,
                    "certificado_base64": null
                }
            ],
            "subcategorias": [
                {
                    "id_subcategoria": 21
                },
                {
                    "id_subcategoria": 22
                }
            ]
        }
    }
*/

CREATE OR REPLACE PROCEDURE PD_AGRICULTORES_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_ID_ENTIDADE IN NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS
    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON                 JSON_OBJECT_T;
    V_DADOS_LOCALIZACAO    JSON_OBJECT_T;
    V_DADOS_VIVENCIA_RURAL JSON_OBJECT_T;
    
    -- DADOS PARA TABELA 'AGRICULTORES'
    V_ID_AGRICULTOR      AGRICULTURA_URBANA_BAURU.AGRICULTORES.ID_AGRICULTOR%TYPE;
    V_AGRICULTOR         AGRICULTURA_URBANA_BAURU.AGRICULTORES.AGRICULTOR%TYPE;
    V_EMAIL              AGRICULTURA_URBANA_BAURU.AGRICULTORES.EMAIL%TYPE;
    V_TELEFONE_1         AGRICULTURA_URBANA_BAURU.AGRICULTORES.TELEFONE_1%TYPE;
    V_TELEFONE_2         AGRICULTURA_URBANA_BAURU.AGRICULTORES.TELEFONE_2%TYPE;
    V_DESCRICAO          AGRICULTURA_URBANA_BAURU.AGRICULTORES.DESCRICAO%TYPE;
    V_FAMILIAR           AGRICULTURA_URBANA_BAURU.AGRICULTORES.FAMILIAR%TYPE;
    V_HECTARES_TOTAL     AGRICULTURA_URBANA_BAURU.AGRICULTORES.HECTARES_TOTAL%TYPE;
    V_HECTARES_PLANTIO   AGRICULTURA_URBANA_BAURU.AGRICULTORES.HECTARES_PLANTIO%TYPE;
    V_COMERCIO           AGRICULTURA_URBANA_BAURU.AGRICULTORES.COMERCIO%TYPE;
    V_CAF                AGRICULTURA_URBANA_BAURU.AGRICULTORES.CAF%TYPE;
    V_VIVENCIA_RURAL     AGRICULTURA_URBANA_BAURU.AGRICULTORES.VIVENCIA_RURAL%TYPE;
    V_ID_LOCAL           AGRICULTURA_URBANA_BAURU.AGRICULTORES.ID_LOCAL%TYPE;

    -- DADOS PARA TABELA 'AGRICULTORES_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_CERTIFICACOES'
    V_CERTIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_ORGANIZACOES'
    V_ORGANIZACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_PONTOS_VENDA'
    V_PONTOS_VENDA       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_QUALIFICACOES'
    V_QUALIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_REDES_SOCIAIS'
    V_REDES_SOCIAIS      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN

    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON              := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UM NOVO AGRICULTOR
    IF P_NOVO_CADASTRO THEN

        -- TABELA AGRICULTORES --
        V_AGRICULTOR           := V_JSON.GET_STRING('agricultor');
        V_EMAIL                := V_JSON.GET_STRING('email');
        V_TELEFONE_1           := V_JSON.GET_NUMBER('telefone_1');
        V_TELEFONE_2           := V_JSON.GET_NUMBER('telefone_2');
        V_FAMILIAR             := V_JSON.GET_STRING('familiar');
        V_HECTARES_TOTAL       := V_JSON.GET_STRING('hectares_total');
        V_HECTARES_PLANTIO     := V_JSON.GET_STRING('hectares_plantio');
        V_COMERCIO             := V_JSON.GET_STRING('comercio');
        V_CAF                  := V_JSON.GET_STRING('caf');
        V_VIVENCIA_RURAL       := V_JSON.GET_STRING('vivencia_rural');
        V_DADOS_VIVENCIA_RURAL := V_JSON.GET_OBJECT('dados_vivencia_rural');

        IF V_AGRICULTOR IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O NOME DO AGRICULTOR');
        END IF;

        IF V_EMAIL IS NOT NULL AND NOT REGEXP_LIKE(V_EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20003, 'INFORME UM EMAIL VÁLIDO');
        END IF;

        IF (V_TELEFONE_1 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_1, '^[1-9][0-9]{9,10}$')) OR (V_TELEFONE_2 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_2, '^[1-9][0-9]{9,10}$')) THEN
            RAISE_APPLICATION_ERROR(-20004, 'INFORME TELEFONES VÁLIDOS');
        END IF;

        IF LENGTHB(V_JSON.GET_STRING('descricao')) > 4000 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO MUITO LONGA');
        ELSE
            V_DESCRICAO := V_JSON.GET_STRING('descricao');
        END IF;

        IF V_FAMILIAR <> 'S' AND V_FAMILIAR <> 'N' THEN
            RAISE_APPLICATION_ERROR(-20006, 'INFORME "SIM" OU "NÃO" SE É UM AGRICULTOR FAMILIAR');
        END IF;

        IF (V_HECTARES_TOTAL IS NOT NULL AND NOT REGEXP_LIKE(V_HECTARES_TOTAL, '^[0-9]+([.,][0-9]+)?$')) OR (V_HECTARES_PLANTIO IS NOT NULL AND NOT REGEXP_LIKE(V_HECTARES_PLANTIO, '^[0-9]+([.,][0-9]+)?$')) THEN
            RAISE_APPLICATION_ERROR(-20007, 'HECTARES TOTAL OU DE PLANTIO DEVEM SER APENAS NÚMEROS');
        ELSE
            IF TO_NUMBER(REPLACE(V_HECTARES_PLANTIO, ',', '.'),'999999999999999D99999999999999','NLS_NUMERIC_CHARACTERS=''.,''') > 
            TO_NUMBER(REPLACE(V_HECTARES_TOTAL, ',', '.'),'999999999999999D99999999999999','NLS_NUMERIC_CHARACTERS=''.,''') THEN
                    RAISE_APPLICATION_ERROR(-20008, 'HECTARES DE PLANTIO NÃO PODE SER MAIOR QUE HECTARES TOTAL');
            END IF;
        END IF;

        IF V_COMERCIO <> 'S' AND V_COMERCIO <> 'N' THEN
            RAISE_APPLICATION_ERROR(-20009, 'INFORME "SIM" OU "NÃO" SE PRATICA COMÉRCIO DE PRODUTOS');
        END IF;

        IF V_CAF IS NOT NULL AND NOT REGEXP_LIKE(V_CAF, '^[A-Za-z0-9.]+$') THEN
            RAISE_APPLICATION_ERROR(-20010, 'INFORME DOCUMENTO CAF VÁLIDO');
        END IF;

        IF (V_VIVENCIA_RURAL <> 'S' AND V_VIVENCIA_RURAL <> 'N') OR V_VIVENCIA_RURAL IS NULL THEN
            RAISE_APPLICATION_ERROR(-20011, 'INFORME "SIM" OU "NÃO" SE PRATICA VIVÊNCIA RURAL NA ÁREA');
        END IF;

        -- CADASTRAMOS A LOCALIZAÇÃO DO AGRICULTOR SE O OBJETO 'LOCALIZACAO' VIER COM VALORES
        IF V_DADOS_LOCALIZACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'INFORME A LOCALIZAÇÃO DA ÁREA');
        ELSE
            PD_LOCALIZACOES_INSERT(V_DADOS_LOCALIZACAO.TO_CLOB(), V_ID_LOCAL);
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DO AGRICULTOR
        INSERT INTO AGRICULTORES (AGRICULTOR, EMAIL, TELEFONE_1, TELEFONE_2, DESCRICAO, FAMILIAR, HECTARES_PLANTIO, HECTARES_TOTAL, COMERCIO, CAF, VIVENCIA_RURAL, ID_LOCAL)
        VALUES (V_AGRICULTOR, V_EMAIL, V_TELEFONE_1, V_TELEFONE_2, V_DESCRICAO, V_FAMILIAR, V_HECTARES_PLANTIO, V_HECTARES_TOTAL, V_COMERCIO, V_CAF, V_VIVENCIA_RURAL, V_ID_LOCAL)
        RETURNING ID_AGRICULTOR INTO V_ID_AGRICULTOR;

    -- FLUXO 2: AGRICULTOR JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_AGRICULTOR := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA AGRICULTORES_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- TABELA AGRICULTORES_CERTIFICACOES --
    V_CERTIFICACOES := V_JSON.GET_ARRAY('certificacoes');

    -- SE O ARRAY DE CERTIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_CERTIFICACOES'
    -- V_CERTIFICACOES CONTÉM AS CERTIFICACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_CERTIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_CERTIFICACOES_INSERT(V_CERTIFICACOES, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- TABELA AGRICULTORES_ORGANIZACOES --
    V_ORGANIZACOES := V_JSON.GET_ARRAY('organizacoes');

    -- SE O ARRAY DE ORGANIZACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_ORGANIZACOES'
    -- V_ORGANIZACOES CONTÉM AS ORGANIZACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_ORGANIZACOES IS NOT NULL THEN
        PD_ENTIDADE_ORGANIZACOES_INSERT(V_ORGANIZACOES, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- TABELA AGRICULTORES_PONTOS_VENDA --
    V_PONTOS_VENDA := V_JSON.GET_ARRAY('pontos_venda');

    -- SE O ARRAY DE PONTOS DE VENDA NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_PONTOS_VENDA'
    -- V_PONTOS_VENDA CONTÉM OS PONTOS DE VENDA, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_PONTOS_VENDA IS NOT NULL THEN
        PD_ENTIDADE_PONTOS_VENDA_INSERT(V_PONTOS_VENDA, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- TABELA AGRICULTORES_QUALIFICACOES --
    V_QUALIFICACOES := V_JSON.GET_ARRAY('qualificacoes');

    -- SE O ARRAY DE QUALIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_QUALIFICACOES'
    -- V_QUALIFICACOES CONTÉM AS QUALIFICAÇÕES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_QUALIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_QUALIFICACOES_INSERT(V_QUALIFICACOES, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- TABELA AGRICULTORES_REDES_SOCIAIS --
    V_REDES_SOCIAIS := V_JSON.GET_ARRAY('redes_sociais');

    -- SE O ARRAY DE REDES SOCIAIS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_REDES_SOCIAIS'
    -- V_REDES_SOCIAIS CONTÉM AS REDES SOCIAIS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_REDES_SOCIAIS IS NOT NULL THEN
        PD_ENTIDADE_REDES_SOCIAIS_INSERT(V_REDES_SOCIAIS, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- TABELA AGRICULTORES_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'AGRICULTORES_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_AGRICULTOR IDENTIFICA O AGRICULTOR
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_ENTIDADE, V_ID_AGRICULTOR);
    END IF;

    -- SE VIVÊNCIA_RURAL FOR 'S' E O OBJETO DADOS_VIVENCIA_RURAL NÃO FOR VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'VIVENCIA_RURAL' E OUTRAS ENTIDADES
    IF V_VIVENCIA_RURAL = 'S' AND V_DADOS_VIVENCIA_RURAL.GET_SIZE() > 0 THEN
        PD_VIVENCIA_RURAL_INSERT(V_DADOS_VIVENCIA_RURAL.TO_CLOB(), V_ID_AGRICULTOR, 'AGRICULTOR', P_NOVO_CADASTRO, 7);
    END IF;

    P_ID_REGISTRO := V_ID_AGRICULTOR;

END PD_AGRICULTORES_INSERT;



/* PD_HORTAS_URBANAS_INSERT 
-> FAZ O INSERT NA TABELA 'HORTAS_URBANAS'
-> RECEBE COMO PARÂMETROS UM JSON CONTENDO AS INFORMAÇÕES DA HORTA URBANA INFORMADAS NO FRONT
-> ESTRUTURA DO JSON:
{
    "horta": "Horta Comunitária Esperança",
    "email": "horta@email.com",
    "telefone_1": "14999999999",
    "telefone_2": "1433334444",
    "descricao": "Horta comunitária dedicada à produção sustentável de hortaliças e à educação ambiental.",
    "hectares_plantio": "2.50",
    "comercio": "S",
    "acessibilidade_pcd": "S",
    "estacionamento": "S",
    "estacionamento_obs": "Estacionamento gratuito com vagas acessíveis.",
    "vivencia_rural": "S",
    "localizacao": {
        "endereco": "Rua das Flores, 150",
        "bairro": "Centro",
        "distrito": "Bauru",
        "cep": "17010000",
        "latitude": "-22.3145",
        "longitude": "-49.0587",
        "id_zona": 1,
        "municipio": "BAURU",
        "uf": "SP"
    },
    "atividades": [
        {
            "id_atividade": 1
        },
        {
            "id_atividade": 3
        }
    ],
    "certificacoes": [
        {
            "id_certificacao": 2,
            "dt_certificado": "15/01/2026",
            "dt_vencimento": "15/01/2027",
            "certificado_base64": null
        },
        {
            "id_certificacao": 5,
            "dt_certificado": "20/03/2026",
            "dt_vencimento": null,
            "certificado_base64": null
        }
    ],
    "organizacoes": [
        {
            "id_organizacao": 4
        },
        {
            "id_organizacao": 7
        }
    ],
    "pontos_venda": [
        {
            "id_ponto": 10
        },
        {
            "id_ponto": 12
        }
    ],
    "qualificacoes": [
        {
            "qualificacao": "Curso de Agricultura Orgânica",
            "dt_qualificacao": "10/08/2025",
            "id_tipo_qualificacao": 1,
            "certificado_base64": null
        },
        {
            "qualificacao": "Manejo Sustentável do Solo",
            "dt_qualificacao": "05/02/2026",
            "id_tipo_qualificacao": 2,
            "certificado_base64": null
        }
    ],
    "redes_sociais": [
        {
            "url_rede": "@horta_esperanca",
            "id_tipo_rede": 1
        },
        {
            "url_rede": "https://www.facebook.com/hortaesperanca",
            "id_tipo_rede": 2
        }
    ],
    "subcategorias": [
        {
            "id_subcategoria": 23
        },
        {
            "id_subcategoria": 24
        }
    ],
    "dados_vivencia_rural": {
        "acessibilidade_pcd": "S",
        "estacionamento": "Estacionamento gratuito para visitantes, com vagas acessíveis.",
        "descricao": "Experiência de turismo rural com visita guiada à horta, apresentação das técnicas de cultivo, contato com a natureza e atividades educativas sobre agricultura sustentável.",
        "funcionamento": "Sábados e domingos, das 08h às 17h",
        "atividades": [
            {
                "id_atividade": 1
            },
            {
                "id_atividade": 3
            }
        ],
        "qualificacoes": [
            {
                "qualificacao": "Turismo rural sustentável",
                "dt_qualificacao": "10/08/2025",
                "id_tipo_qualificacao": 1,
                "certificado_base64": null
            },
            {
                "qualificacao": "Educação ambiental",
                "dt_qualificacao": "05/02/2026",
                "id_tipo_qualificacao": 2,
                "certificado_base64": null
            }
        ],
        "subcategorias": [
            {
                "id_subcategoria": 21
            },
            {
                "id_subcategoria": 22
            }
        ]
    },
}
*/

CREATE OR REPLACE PROCEDURE PD_HORTAS_URBANAS_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_ID_ENTIDADE IN NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS

    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON                 JSON_OBJECT_T;
    V_DADOS_LOCALIZACAO    JSON_OBJECT_T;
    V_DADOS_VIVENCIA_RURAL JSON_OBJECT_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS'
    V_ID_HORTA           AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.ID_HORTA%TYPE;
    V_HORTA              AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.HORTA%TYPE;
    V_EMAIL              AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.EMAIL%TYPE;
    V_TELEFONE_1         AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.TELEFONE_1%TYPE;
    V_TELEFONE_2         AGRICULTURA_URBANA_BAURU.HORTAS_URBANASS.TELEFONE_2%TYPE;
    V_DESCRICAO          AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.DESCRICAO%TYPE;
    V_HECTARES_PLANTIO   AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.HECTARES_PLANTIO%TYPE;
    V_COMERCIO           AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.COMERCIO%TYPE;
    V_ACESSIBILIDADE_PCD AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.ACESSIBILIDADE_PCD%TYPE;
    V_ESTACIONAMENTO     AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.ESTACIONAMENTO%TYPE;
    V_ESTACIONAMENTO_OBS AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.ESTACIONAMENTO_OBS%TYPE;
    V_ID_LOCAL           AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.ID_LOCAL%TYPE;
    V_VIVENCIA_RURAL     AGRICULTURA_URBANA_BAURU.HORTAS_URBANAS.VIVENCIA_RURAL%TYPE;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_CERTIFICACOES'
    V_CERTIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_ORGANIZACOES'
    V_ORGANIZACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_PONTOS_VENDA'
    V_PONTOS_VENDA       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_QUALIFICACOES'
    V_QUALIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_REDES_SOCIAIS'
    V_REDES_SOCIAIS      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'HORTAS_URBANAS_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN
    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UMA NOVA HORTA URBANA
    IF P_NOVO_CADASTRO THEN

        -- TABELA HORTAS URBANAS --
        V_HORTA                := V_JSON.GET_STRING('horta');
        V_EMAIL                := V_JSON.GET_STRING('email');
        V_TELEFONE_1           := V_JSON.GET_NUMBER('telefone_1');
        V_TELEFONE_2           := V_JSON.GET_NUMBER('telefone_2');
        V_HECTARES_PLANTIO     := V_JSON.GET_STRING('hectares_plantio');
        V_COMERCIO             := V_JSON.GET_STRING('comercio');
        V_ACESSIBILIDADE_PCD   := V_JSON.GET_STRING('acessibilidade_pcd');
        V_ESTACIONAMENTO       := V_JSON.GET_STRING('estacionamento');
        V_ESTACIONAMENTO_OBS   := V_JSON.GET_STRING('estacionamento_obs');
        V_VIVENCIA_RURAL       := V_JSON.GET_STRING('vivencia_rural');
        V_DADOS_VIVENCIA_RURAL := V_JSON.GET_OBJECT('dados_vivencia_rural');

        IF V_HORTA IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O NOME DA HORTA');
        END IF;

        IF V_EMAIL IS NOT NULL AND NOT REGEXP_LIKE(V_EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20003, 'INFORME UM EMAIL VÁLIDO');
        END IF;

        IF (V_TELEFONE_1 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_1, '^[1-9][0-9]{9,10}$')) OR (V_TELEFONE_2 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_2, '^[1-9][0-9]{9,10}$')) THEN
            RAISE_APPLICATION_ERROR(-20004, 'INFORME TELEFONES VÁLIDOS');
        END IF;

        IF LENGTHB(V_JSON.GET_STRING('descricao')) > 4000 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO MUITO LONGA');
        ELSE
            V_DESCRICAO := V_JSON.GET_STRING('descricao');
        END IF;

        IF V_HECTARES_PLANTIO IS NOT NULL AND NOT REGEXP_LIKE(V_HECTARES_PLANTIO, '^[0-9]+([.,][0-9]+)?$') THEN
            RAISE_APPLICATION_ERROR(-20007, 'HECTARES DE PLANTIO DEVE SER APENAS NÚMEROS');
        END IF;

        IF V_COMERCIO <> 'S' AND V_COMERCIO <> 'N' THEN
            RAISE_APPLICATION_ERROR(-20009, 'INFORME "SIM" OU "NÃO" SE PRATICA COMÉRCIO DE PRODUTOS');
        END IF;

        IF (V_VIVENCIA_RURAL <> 'S' AND V_VIVENCIA_RURAL <> 'N') OR V_VIVENCIA_RURAL IS NULL THEN
            RAISE_APPLICATION_ERROR(-20011, 'INFORME "SIM" OU "NÃO" SE PRATICA VIVÊNCIA RURAL NA ÁREA');
        END IF;

        -- CADASTRAMOS A LOCALIZAÇÃO DA HORTA URBANA SE O OBJETO 'LOCALIZACAO' VIER COM VALORES
        IF V_DADOS_LOCALIZACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'INFORME A LOCALIZAÇÃO DA ÁREA');
        ELSE
            PD_LOCALIZACOES_INSERT(V_DADOS_LOCALIZACAO.TO_CLOB(), V_ID_LOCAL);
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DA HORTA URBANA
        INSERT INTO HORTAS_URBANAS (HORTA, EMAIL, TELEFONE_1, TELEFONE_2, DESCRICAO, HECTARES_PLANTIO, COMERCIO, ACESSIBILIDADE_PCD, ESTACIONAMENTO, ESTACIONAMENTO_OBS, VIVENCIA_RURAL, ID_LOCAL)
        VALUES (V_HORTA, V_EMAIL, V_TELEFONE_1, V_TELEFONE_2, V_DESCRICAO, V_HECTARES_PLANTIO, V_COMERCIO, V_ACESSIBILIDADE_PCD, V_ESTACIONAMENTO, V_ESTACIONAMENTO_OBS, V_VIVENCIA_RURAL, V_ID_LOCAL)
        RETURNING ID_HORTA INTO V_ID_HORTA;

    -- FLUXO 2: HORTA URBANA JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_HORTA := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA HORTAS_URBANAS_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- TABELA HORTAS_URBANAS_CERTIFICACOES --
    V_CERTIFICACOES := V_JSON.GET_ARRAY('certificacoes');

    -- SE O ARRAY DE CERTIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_CERTIFICACOES'
    -- V_CERTIFICACOES CONTÉM AS CERTIFICACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_CERTIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_CERTIFICACOES_INSERT(V_CERTIFICACOES, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- TABELA HORTAS_URBANAS_ORGANIZACOES --
    V_ORGANIZACOES := V_JSON.GET_ARRAY('organizacoes');

    -- SE O ARRAY DE ORGANIZACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_ORGANIZACOES'
    -- V_ORGANIZACOES CONTÉM AS ORGANIZACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_ORGANIZACOES IS NOT NULL THEN
        PD_ENTIDADE_ORGANIZACOES_INSERT(V_ORGANIZACOES, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- TABELA HORTAS_URBANAS_PONTOS_VENDA --
    V_PONTOS_VENDA := V_JSON.GET_ARRAY('pontos_venda');

    -- SE O ARRAY DE PONTOS DE VENDA NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_PONTOS_VENDA'
    -- V_PONTOS_VENDA CONTÉM OS PONTOS DE VENDA, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_PONTOS_VENDA IS NOT NULL THEN
        PD_ENTIDADE_PONTOS_VENDA_INSERT(V_PONTOS_VENDA, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- TABELA HORTAS_URBANAS_QUALIFICACOES --
    V_QUALIFICACOES := V_JSON.GET_ARRAY('qualificacoes');

    -- SE O ARRAY DE QUALIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_QUALIFICACOES'
    -- V_QUALIFICACOES CONTÉM AS QUALIFICAÇÕES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_QUALIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_QUALIFICACOES_INSERT(V_QUALIFICACOES, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- TABELA HORTAS_URBANAS_REDES_SOCIAIS --
    V_REDES_SOCIAIS := V_JSON.GET_ARRAY('redes_sociais');

    -- SE O ARRAY DE REDES SOCIAIS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_REDES_SOCIAIS'
    -- V_REDES_SOCIAIS CONTÉM AS REDES SOCIAIS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_REDES_SOCIAIS IS NOT NULL THEN
        PD_ENTIDADE_REDES_SOCIAIS_INSERT(V_REDES_SOCIAIS, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- TABELA HORTAS_URBANAS_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'HORTAS_URBANAS_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A HORTA
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_ENTIDADE, V_ID_HORTA);
    END IF;

    -- SE VIVÊNCIA_RURAL FOR 'S' E O OBJETO DADOS_VIVENCIA_RURAL NÃO FOR VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'VIVENCIA_RURAL' E OUTRAS ENTIDADES
    IF V_VIVENCIA_RURAL = 'S' AND V_DADOS_VIVENCIA_RURAL.GET_SIZE() > 0 THEN
        PD_VIVENCIA_RURAL_INSERT(V_DADOS_VIVENCIA_RURAL.TO_CLOB(), V_ID_HORTA, 'HORTA', P_NOVO_CADASTRO, 7);
    END IF;

    P_ID_REGISTRO := V_ID_HORTA;

END PD_HORTAS_URBANAS_INSERT;



/* PROCEDURE PD_FEIRAS_MUNICIPAIS_INSERT
-> FAZ O INSERT NA TABELA 'FEIRAS_MUNICIPAIS'
-> RECEBE COMO PARÂMETROS UM JSON CONTENDO AS INFORMAÇÕES DE FEIRAS MUNICIPAIS
-> ESTRUTURA DO JSON:
{
    "feira": "Feira Municipal do Produtor Rural",
    "email": "feira@email.com",
    "funcionamento": "Terças e sábados, das 07h às 12h",
    "localizacao": {
        "endereco": "Praça Rui Barbosa, Centro",
        "bairro": "Centro",
        "distrito": "Bauru",
        "cep": "17010000",
        "latitude": "-22.3145",
        "longitude": "-49.0587",
        "id_zona": 1,
        "municipio": "BAURU",
        "uf": "SP"
    },
    "atividades": [
        {
            "id_atividade": 1
        },
        {
            "id_atividade": 3
        }
    ],
    "certificacoes": [
        {
            "id_certificacao": 2,
            "dt_certificado": "15/01/2026",
            "dt_vencimento": "15/01/2027",
            "certificado_base64": null
        },
        {
            "id_certificacao": 5,
            "dt_certificado": "20/03/2026",
            "dt_vencimento": null,
            "certificado_base64": null
        }
    ],
    "organizacoes": [
        {
            "id_organizacao": 4
        },
        {
            "id_organizacao": 7
        }
    ],
    "redes_sociais": [
        {
            "url_rede": "@feiraprodutorbauru",
            "id_tipo_rede": 1
        },
        {
            "url_rede": "https://www.facebook.com/feiraprodutorbauru",
            "id_tipo_rede": 2
        }
    ],
    "subcategorias": [
        {
            "id_subcategoria": 21
        },
        {
            "id_subcategoria": 22
        }
    ]
} */

CREATE OR REPLACE PROCEDURE PD_FEIRAS_MUNICIPAIS_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_ID_ENTIDADE IN NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS

    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON               JSON_OBJECT_T;
    V_DADOS_LOCALIZACAO  JSON_OBJECT_T;

    -- DADOS PARA TABELA 'FEIRAS_MUNICIPAIS'
    V_ID_FEIRA      AGRICULTURA_URBANA_BAURU.FEIRAS_MUNICIPAIS.ID_FEIRA%TYPE;
    V_FEIRA         AGRICULTURA_URBANA_BAURU.FEIRAS_MUNICIPAIS.FEIRA%TYPE;
    V_EMAIL         AGRICULTURA_URBANA_BAURU.FEIRAS_MUNICIPAIS.EMAIL%TYPE;
    V_FUNCIONAMENTO AGRICULTURA_URBANA_BAURU.FEIRAS_MUNICIPAIS.FUNCIONAMENTO%TYPE;
    V_ID_LOCAL      AGRICULTURA_URBANA_BAURU.FEIRAS_MUNICIPAIS.ID_LOCAL%TYPE;

    -- DADOS PARA TABELA 'FEIRAS_MUNICIPAIS_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'FEIRAS_MUNICIPAIS_CERTIFICACOES'
    V_CERTIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'FEIRAS_MUNICIPAIS_ORGANIZACOES'
    V_ORGANIZACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'FEIRAS_MUNICIPAIS_REDES_SOCIAIS'
    V_REDES_SOCIAIS      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'FEIRAS_MUNICIPAIS_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN
    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UMA NOVA FEIRA MUNICIPAL
    IF P_NOVO_CADASTRO THEN

        -- TABELA FEIRAS MUNICIPAIS --
        V_FEIRA         := V_JSON.GET_STRING('feira');
        V_EMAIL         := V_JSON.GET_STRING('email');
        V_FUNCIONAMENTO := V_JSON.GET_STRING('funcionamento');


        IF V_FEIRA IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O NOME DA FEIRA MUNICIPAL');
        END IF;

        IF V_EMAIL IS NOT NULL AND NOT REGEXP_LIKE(V_EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20003, 'INFORME UM EMAIL VÁLIDO');
        END IF;

        IF LENGTHB(V_JSON.GET_STRING('funcionamento')) > 480 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO DO FUNCIONAMENTO MUITO LONGA');
        ELSE
            V_FUNCIONAMENTO := V_JSON.GET_STRING('funcionamento');
        END IF;

        -- CADASTRAMOS A LOCALIZAÇÃO DA FEIRA MUNICIPAL SE O OBJETO 'LOCALIZACAO' VIER COM VALORES
        IF V_DADOS_LOCALIZACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'INFORME A LOCALIZAÇÃO DA FEIRA MUNICIPAL');
        ELSE
            PD_LOCALIZACOES_INSERT(V_DADOS_LOCALIZACAO.TO_CLOB(), V_ID_LOCAL);
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DA FEIRA MUNICIPAL
        INSERT INTO FEIRAS_MUNICIPAIS (FEIRA, EMAIL, FUNCIONAMENTO, ID_LOCAL)
        VALUES (V_FEIRA, V_EMAIL, V_FUNCIONAMENTO, V_ID_LOCAL)
        RETURNING ID_FEIRA INTO V_ID_FEIRA;

    -- FLUXO 2: FEIRA MUNICIPAL JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_FEIRA := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA FEIRAS_MUNICIPAIS_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'FEIRAS_MUNICIPAIS_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_FEIRA IDENTIFICA A FEIRA
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_ENTIDADE, V_ID_FEIRA);
    END IF;

    -- TABELA FEIRAS_MUNICIPAIS_CERTIFICACOES --
    V_CERTIFICACOES := V_JSON.GET_ARRAY('certificacoes');

    -- SE O ARRAY DE CERTIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'FEIRAS_MUNICIPAIS_CERTIFICACOES'
    -- V_CERTIFICACOES CONTÉM AS CERTIFICACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_FEIRA IDENTIFICA A FEIRA
    IF V_CERTIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_CERTIFICACOES_INSERT(V_CERTIFICACOES, P_ID_ENTIDADE, V_ID_FEIRA);
    END IF;

    -- TABELA FEIRAS_MUNICIPAIS_ORGANIZACOES --
    V_ORGANIZACOES := V_JSON.GET_ARRAY('organizacoes');

    -- SE O ARRAY DE ORGANIZACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'FEIRAS_MUNICIPAIS_ORGANIZACOES'
    -- V_ORGANIZACOES CONTÉM AS ORGANIZACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_FEIRA IDENTIFICA A FEIRA
    IF V_ORGANIZACOES IS NOT NULL THEN
        PD_ENTIDADE_ORGANIZACOES_INSERT(V_ORGANIZACOES, P_ID_ENTIDADE, V_ID_FEIRA);
    END IF;

    -- TABELA FEIRAS_MUNICIPAIS_REDES_SOCIAIS --
    V_REDES_SOCIAIS := V_JSON.GET_ARRAY('redes_sociais');

    -- SE O ARRAY DE REDES SOCIAIS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'FEIRAS_MUNICIPAIS_REDES_SOCIAIS'
    -- V_REDES_SOCIAIS CONTÉM AS REDES SOCIAIS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_FEIRA IDENTIFICA A FEIRA
    IF V_REDES_SOCIAIS IS NOT NULL THEN
        PD_ENTIDADE_REDES_SOCIAIS_INSERT(V_REDES_SOCIAIS, P_ID_ENTIDADE, V_ID_FEIRA);
    END IF;

    -- TABELA FEIRAS_MUNICIPAIS_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'FEIRAS_MUNICIPAIS_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_HORTA IDENTIFICA A FEIRA
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_ENTIDADE, V_ID_FEIRA);
    END IF;

    P_ID_REGISTRO := V_ID_FEIRA;

END PD_FEIRAS_MUNICIPAIS_INSERT;



/* PROCEDURE PD_ATRATIVOS_TURISTICOS_INSERT
-> FAZ O INSERT DA ENTIDADE 'ATRATIVOS TURISTICOS'
-> RECEBE COMO PARÂMETRO UM JSON CONTENDO AS INFOS DE UM ATRATIVO TURÍSTICO
-> ESTRUTURA DO JSON:

{
    "atrativo": "Parque Ecológico Municipal",
    "email": "contato@atrativo.com.br",
    "telefone_1": "1432000000",
    "telefone_2": "14999999999",
    "descricao": "Espaço destinado ao turismo, lazer e contato com a natureza.",
    "acessibilidade_pcd": "S",
    "estacionamento": "S",
    "estacionamento_obs": "Estacionamento disponível para visitantes.",
    "funcionamento": "Terça a domingo, das 08h às 17h",
    "localizacao": {
        "endereco": "Avenida Exemplo, 100",
        "bairro": "Centro",
        "distrito": "Bauru",
        "cep": "17010000",
        "latitude": "-22.3145",
        "longitude": "-49.0587",
        "id_zona": 1,
        "municipio": "BAURU",
        "uf": "SP"
    },
    "atividades": [
        {
            "id_atividade": 1
        },
        {
            "id_atividade": 3
        }
    ],
    "certificacoes": [
        {
            "id_certificacao": 2,
            "dt_certificado": "15/01/2026",
            "dt_vencimento": "15/01/2027",
            "certificado_base64": null
        },
        {
            "id_certificacao": 5,
            "dt_certificado": "20/03/2026",
            "dt_vencimento": null,
            "certificado_base64": null
        }
    ],
    "organizacoes": [
        {
            "id_organizacao": 4
        },
        {
            "id_organizacao": 7
        }
    ],
    "qualificacoes": [
        {
            "qualificacao": "Turismo sustentável",
            "dt_qualificacao": "10/08/2025",
            "id_tipo_qualificacao": 1,
            "certificado_base64": null
        },
        {
            "qualificacao": "Educação ambiental",
            "dt_qualificacao": "05/02/2026",
            "id_tipo_qualificacao": 2,
            "certificado_base64": null
        }
    ],
    "redes_sociais": [
        {
            "url_rede": "@atrativo_turistico",
            "id_tipo_rede": 1
        },
        {
            "url_rede": "https://www.facebook.com/atrativo.turistico",
            "id_tipo_rede": 2
        }
    ],
    "subcategorias": [
        {
            "id_subcategoria": 21
        },
        {
            "id_subcategoria": 22
        }
    ]
}
*/

CREATE OR REPLACE PROCEDURE PD_ATRATIVOS_TURISTICOS_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_ID_ENTIDADE IN NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS

    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON               JSON_OBJECT_T;
    V_DADOS_LOCALIZACAO  JSON_OBJECT_T;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS'
    V_ID_ATRATIVO           AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.ID_ATRATIVO%TYPE;
    V_ATRATIVO              AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.ATRATIVO%TYPE;
    V_EMAIL                 AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.EMAIL%TYPE;
    V_TELEFONE_1            AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.TELEFONE_1%TYPE;
    V_TELEFONE_2            AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.TELEFONE_2%TYPE;
    V_DESCRICAO             AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.DESCRICAO%TYPE;
    V_ACESSIBILIDADE_PCD    AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.ACESSIBILIDADE_PCD%TYPE;
    V_ESTACIONAMENTO        AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.ESTACIONAMENTO%TYPE;
    V_ESTACIONAMENTO_OBS    AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.ESTACIONAMENTO_OBS%TYPE;
    V_FUNCIONAMENTO         AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.FUNCIONAMENTO%TYPE;
    V_ID_LOCAL              AGRICULTURA_URBANA_BAURU.ATRATIVOS_TURISTICOS.ID_LOCAL%TYPE;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS_CERTIFICACOES'
    V_CERTIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS_ORGANIZACOES'
    V_ORGANIZACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS_QUALIFICACOES'
    V_QUALIFICACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS_REDES_SOCIAIS'
    V_REDES_SOCIAIS      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'ATRATIOS_TURISTICOS_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN
    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UM NOVO ATRATIVO TURÍSTICO
    IF P_NOVO_CADASTRO THEN

        -- TABELA ATRATIVOS TURISTICOS --
        V_ATRATIVO              := V_JSON.GET_STRING('atrativo');
        V_EMAIL                 := V_JSON.GET_STRING('email');
        V_TELEFONE_1            := V_JSON.GET_STRING('telefone_1');
        V_TELEFONE_2            := V_JSON.GET_STRING('telefone_2');
        V_DESCRICAO             := V_JSON.GET_STRING('descricao');
        V_ACESSIBILIDADE_PCD    := V_JSON.GET_STRING('acessibilidade_pcd');
        V_ESTACIONAMENTO        := V_JSON.GET_STRING('estacionamento');
        V_ESTACIONAMENTO_OBS    := V_JSON.GET_STRING('estacionamento_obs');
        V_FUNCIONAMENTO         := V_JSON.GET_STRING('funcionamento');


        IF V_ATRATIVO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O NOME DO ATRATIVO');
        END IF;

        IF V_EMAIL IS NOT NULL AND NOT REGEXP_LIKE(V_EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20003, 'INFORME UM EMAIL VÁLIDO');
        END IF;

        IF (V_TELEFONE_1 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_1, '^[1-9][0-9]{9,10}$')) OR (V_TELEFONE_2 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_2, '^[1-9][0-9]{9,10}$')) THEN
            RAISE_APPLICATION_ERROR(-20004, 'INFORME TELEFONES VÁLIDOS');
        END IF;

        IF LENGTHB(V_JSON.GET_STRING('descricao')) > 4000 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO MUITO LONGA');
        ELSE
            V_DESCRICAO := V_JSON.GET_STRING('descricao');
        END IF;

        -- CADASTRAMOS A LOCALIZAÇÃO DO ATRATIVO TURISTICO SE O OBJETO 'LOCALIZACAO' VIER COM VALORES
        IF V_DADOS_LOCALIZACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'INFORME A LOCALIZAÇÃO DA ÁREA');
        ELSE
            PD_LOCALIZACOES_INSERT(V_DADOS_LOCALIZACAO.TO_CLOB(), V_ID_LOCAL);
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DO ATRATIVO
        INSERT INTO ATRATIVOS_TURISTICOS (ATRATIVO, EMAIL, TELEFONE_1, TELEFONE_2, DESCRICAO, ACESSIBILIDADE_PCD, ESTACIONAMENTO, ESTACIONAMENTO_OBS, FUNCIONAMENTO, ID_LOCAL)
        VALUES (V_ATRATIVO, V_EMAIL, V_TELEFONE_1, V_TELEFONE_2, V_DESCRICAO, V_ACESSIBILIDADE_PCD, V_ESTACIONAMENTO, V_ESTACIONAMENTO_OBS, V_FUNCIONAMENTO, V_ID_LOCAL)
        RETURNING ID_ATRATIVO INTO V_ID_ATRATIVO;

    -- FLUXO 2: ATRATIVO JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_ATRATIVO := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA ATRATIVOS_TURISTICOS_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'ATRATIVOS_TURISTICOS_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_ATRATIVO IDENTIFICA O ATRATIVO
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_ENTIDADE, V_ID_ATRATIVO);
    END IF;

    -- TABELA ATRATIVOS_TURISTICOS_CERTIFICACOES --
    V_CERTIFICACOES := V_JSON.GET_ARRAY('certificacoes');

    -- SE O ARRAY DE CERTIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'ATRATIVOS_TURISTICOS_CERTIFICACOES'
    -- V_CERTIFICACOES CONTÉM AS CERTIFICACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_ATRATIVO IDENTIFICA O ATRATIVO
    IF V_CERTIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_CERTIFICACOES_INSERT(V_CERTIFICACOES, P_ID_ENTIDADE, V_ID_ATRATIVO);
    END IF;

    -- TABELA ATRATIVOS_TURISTICOS_ORGANIZACOES --
    V_ORGANIZACOES := V_JSON.GET_ARRAY('organizacoes');

    -- SE O ARRAY DE ORGANIZACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'ATRATIVOS_TURISTICOS_ORGANIZACOES'
    -- V_ORGANIZACOES CONTÉM AS ORGANIZACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_ATRATIVO IDENTIFICA O ATRATIVO
    IF V_ORGANIZACOES IS NOT NULL THEN
        PD_ENTIDADE_ORGANIZACOES_INSERT(V_ORGANIZACOES, P_ID_ENTIDADE, V_ID_ATRATIVO);
    END IF;

    -- TABELA ATRATIVOS_TURISTICOS_QUALIFICACOES --
    V_QUALIFICACOES := V_JSON.GET_ARRAY('qualificacoes');

    -- SE O ARRAY DE QUALIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'ATRATIVOS_TURISTICOS_QUALIFICACOES'
    -- V_QUALIFICACOES CONTÉM AS QUALIFICAÇÕES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_ATRATIVO IDENTIFICA O ATRATIVO
    IF V_QUALIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_QUALIFICACOES_INSERT(V_QUALIFICACOES, P_ID_ENTIDADE, V_ID_ATRATIVO);
    END IF;

    -- TABELA ATRATIVOS_TURISTICOS_REDES_SOCIAIS --
    V_REDES_SOCIAIS := V_JSON.GET_ARRAY('redes_sociais');

    -- SE O ARRAY DE REDES SOCIAIS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'ATRATIVOS_TURISTICOS_REDES_SOCIAIS'
    -- V_REDES_SOCIAIS CONTÉM AS REDES SOCIAIS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_ATRATIVO IDENTIFICA O ATRATIVO
    IF V_REDES_SOCIAIS IS NOT NULL THEN
        PD_ENTIDADE_REDES_SOCIAIS_INSERT(V_REDES_SOCIAIS, P_ID_ENTIDADE, V_ID_ATRATIVO);
    END IF;

    -- TABELA ATRATIVOS_TURISTICOS_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'ATRATIVOS_TURISTICOS_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_ATRATIVO IDENTIFICA O ATRATIVO
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_ENTIDADE, V_ID_ATRATIVO);
    END IF;

    P_ID_REGISTRO := V_ID_ATRATIVO;

END PD_ATRATIVOS_TURISTICOS_INSERT;





/* PROCEDURE PD_SERVICOS_AGRICULTURA_INSERT
-> FAZ O INSERT DA ENTIDADE 'SERVICOS AGRICULTURA'
-> RECEBE COMO PARÂMETRO UM JSON CONTENDO AS INFOS DE UM SERVIÇO PARA AGRICULTURA
-> ESTRUTURA DO JSON:

{
    "servico": "Análise de Solo e Fertilidade",
    "cnpj": "12345678000195",
    "email": "contato@exemplo.com.br",
    "telefone_1": "1432000000",
    "telefone_2": "14999999999",
    "descricao": "Realização de análises de solo para avaliação da fertilidade, identificação de nutrientes e orientação técnica para o manejo agrícola.",
    "funcionamento": "Segunda a sexta-feira, das 08h às 17h",
    "id_tipo_servico": 1,
    "localizacao": {
        "endereco": "Avenida Exemplo, 100",
        "bairro": "Centro",
        "distrito": "Bauru",
        "cep": "17010000",
        "latitude": "-22.3145",
        "longitude": "-49.0587",
        "id_zona": 1,
        "municipio": "BAURU",
        "uf": "SP"
    },
    "atividades": [
        {
            "id_atividade": 1
        },
        {
            "id_atividade": 3
        }
    ],
    "certificacoes": [
        {
            "id_certificacao": 2,
            "dt_certificado": "15/01/2026",
            "dt_vencimento": "15/01/2027",
            "certificado_base64": null
        },
        {
            "id_certificacao": 5,
            "dt_certificado": "20/03/2026",
            "dt_vencimento": null,
            "certificado_base64": null
        }
    ],
    "organizacoes": [
        {
            "id_organizacao": 4
        },
        {
            "id_organizacao": 7
        }
    ],
    "qualificacoes": [
        {
            "qualificacao": "Análise de fertilidade do solo",
            "dt_qualificacao": "10/08/2025",
            "id_tipo_qualificacao": 1,
            "certificado_base64": null
        },
        {
            "qualificacao": "Manejo e conservação do solo",
            "dt_qualificacao": "05/02/2026",
            "id_tipo_qualificacao": 2,
            "certificado_base64": null
        }
    ],
    "redes_sociais": [
        {
            "url_rede": "@servico_agricola",
            "id_tipo_rede": 1
        },
        {
            "url_rede": "https://www.facebook.com/servico.agricola",
            "id_tipo_rede": 2
        }
    ],
    "subcategorias": [
        {
            "id_subcategoria": 21
        },
        {
            "id_subcategoria": 22
        }
    ]
}
*/

CREATE OR REPLACE PROCEDURE PD_SERVICOS_AGRICULTURA_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_ID_ENTIDADE IN NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS
    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON               JSON_OBJECT_T;
    V_DADOS_LOCALIZACAO  JSON_OBJECT_T;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA'
    V_ID_SERVICO       AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.ID_SERVICO%TYPE;
    V_SERVICO          AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.SERVICO%TYPE;
    V_CNPJ             AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.CNPJ%TYPE;
    V_EMAIL            AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.EMAIL%TYPE;
    V_TELEFONE_1       AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.TELEFONE_1%TYPE;
    V_TELEFONE_2       AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.TELEFONE_2%TYPE;
    V_DESCRICAO        AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.DESCRICAO%TYPE;
    V_FUNCIONAMENTO    AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.FUNCIONAMENTO%TYPE;
    V_ID_LOCAL         AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.ID_LOCAL%TYPE;
    V_ID_TIPO_SERVICO  AGRICULTURA_URBANA_BAURU.SERVICOS_AGRICULTURA.ID_TIPO_SERVICO%TYPE;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA_CERTIFICACOES'
    V_CERTIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA_ORGANIZACOES'
    V_ORGANIZACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA_QUALIFICACOES'
    V_QUALIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA_REDES_SOCIAIS'
    V_REDES_SOCIAIS      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'SERVICOS_AGRICULTURA_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN

    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UM NOVO SERVIÇO
    IF P_NOVO_CADASTRO THEN

        -- TABELA SERVIÇOS --
        V_SERVICO          := V_JSON.GET_STRING('servico');
        V_CNPJ             := V_JSON.GET_STRING('cnpj');
        V_EMAIL            := V_JSON.GET_STRING('email');
        V_TELEFONE_1       := V_JSON.GET_NUMBER('telefone_1');
        V_TELEFONE_2       := V_JSON.GET_NUMBER('telefone_2');
        V_FUNCIONAMENTO    := V_JSON.GET_STRING('funcionamento');
        V_ID_TIPO_SERVICO  := V_JSON.GET_NUMBER('id_tipo_servico');

        IF V_SERVICO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O NOME DO SERVIÇO');
        END IF;

        IF V_CNPJ IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O CNPJ DO SERVIÇO');
        END IF;

        IF V_EMAIL IS NOT NULL AND NOT REGEXP_LIKE(V_EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20003, 'INFORME UM EMAIL VÁLIDO');
        END IF;

        IF (V_TELEFONE_1 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_1, '^[1-9][0-9]{9,10}$')) OR (V_TELEFONE_2 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_2, '^[1-9][0-9]{9,10}$')) THEN
            RAISE_APPLICATION_ERROR(-20004, 'INFORME TELEFONES VÁLIDOS');
        END IF;

        IF LENGTHB(V_JSON.GET_STRING('descricao')) > 4000 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO MUITO LONGA');
        ELSE
            V_DESCRICAO := V_JSON.GET_STRING('descricao');
        END IF;

        -- CADASTRAMOS A LOCALIZAÇÃO DO SERVIÇO SE O OBJETO 'LOCALIZACAO' VIER COM VALORES
        IF V_DADOS_LOCALIZACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20012, 'INFORME A LOCALIZAÇÃO DA ÁREA');
        ELSE
            PD_LOCALIZACOES_INSERT(V_DADOS_LOCALIZACAO.TO_CLOB(), V_ID_LOCAL);
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DO SERVIÇO
        INSERT INTO SERVICOS_AGRICULTURA (SERVICO, CNPJ, EMAIL, TELEFONE_1, TELEFONE_2, DESCRICAO, FUNCIONAMENTO, ID_LOCAL)
        VALUES (V_SERVICO, V_CNPJ, V_EMAIL, V_TELEFONE_1, V_TELEFONE_2, V_DESCRICAO, V_FUNCIONAMENTO, V_ID_LOCAL)
        RETURNING ID_SERVICO INTO V_ID_SERVICO;

    -- FLUXO 2: SERVIÇO JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_SERVICO := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA SERVICOS_AGRICULTURA_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'SERVICOS_AGRICULTURA_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_SERVICO IDENTIFICA O SERVICO
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_ENTIDADE, V_ID_SERVICO);
    END IF;

    -- TABELA SERVICOS_AGRICULTURA_CERTIFICACOES --
    V_CERTIFICACOES := V_JSON.GET_ARRAY('certificacoes');

    -- SE O ARRAY DE CERTIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'SERVICOS_AGRICULTURA_CERTIFICACOES'
    -- V_CERTIFICACOES CONTÉM AS CERTIFICACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_SERVICO IDENTIFICA O SERVICO
    IF V_CERTIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_CERTIFICACOES_INSERT(V_CERTIFICACOES, P_ID_ENTIDADE, V_ID_SERVICO);
    END IF;

    -- TABELA SERVICOS_AGRICULTURA_ORGANIZACOES --
    V_ORGANIZACOES := V_JSON.GET_ARRAY('organizacoes');

    -- SE O ARRAY DE ORGANIZACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'SERVICOS_AGRICULTURA_ORGANIZACOES'
    -- V_ORGANIZACOES CONTÉM AS ORGANIZACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_SERVICO IDENTIFICA O SERVICO
    IF V_ORGANIZACOES IS NOT NULL THEN
        PD_ENTIDADE_ORGANIZACOES_INSERT(V_ORGANIZACOES, P_ID_ENTIDADE, V_ID_SERVICO);
    END IF;

    -- TABELA SERVICOS_AGRICULTURA_QUALIFICACOES --
    V_QUALIFICACOES := V_JSON.GET_ARRAY('qualificacoes');

    -- SE O ARRAY DE QUALIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'SERVICOS_AGRICULTURA_QUALIFICACOES'
    -- V_QUALIFICACOES CONTÉM AS QUALIFICAÇÕES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_SERVICO IDENTIFICA O SERVICO
    IF V_QUALIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_QUALIFICACOES_INSERT(V_QUALIFICACOES, P_ID_ENTIDADE, V_ID_SERVICO);
    END IF;

    -- TABELA SERVICOS_AGRICULTURA_REDES_SOCIAIS --
    V_REDES_SOCIAIS := V_JSON.GET_ARRAY('redes_sociais');

    -- SE O ARRAY DE REDES SOCIAIS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'SERVICOS_AGRICULTURA_REDES_SOCIAIS'
    -- V_REDES_SOCIAIS CONTÉM AS REDES SOCIAIS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_SERVICO IDENTIFICA O SERVICO
    IF V_REDES_SOCIAIS IS NOT NULL THEN
        PD_ENTIDADE_REDES_SOCIAIS_INSERT(V_REDES_SOCIAIS, P_ID_ENTIDADE, V_ID_SERVICO);
    END IF;

    -- TABELA SERVICOS_AGRICULTURA_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'SERVICOS_AGRICULTURA_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_SERVICO IDENTIFICA O SERVICO
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_ENTIDADE, V_ID_SERVICO);
    END IF;

    P_ID_REGISTRO := V_ID_SERVICO;

END PD_SERVICOS_AGRICULTURA_INSERT;




/* PROCEDURE PD_INICIATIVAS_PUBLICAS_INSERT
-> FAZ O INSERT DA ENTIDADE 'INICIATIVAS PUBLICAS'
-> RECEBE COMO PARÂMETRO UM JSON CONTENDO AS INFOS DE UMA INICIATIVA PÚBLICA
-> ESTRUTURA DO JSON:

{
    "iniciativa": "Programa Municipal de Agricultura Urbana",
    "email": "agriculturaurbana@bauru.sp.gov.br",
    "telefone_1": "1432000000",
    "telefone_2": "14999999999",
    "descricao": "Programa destinado ao incentivo da agricultura urbana, ao fortalecimento da produção de alimentos, à promoção da segurança alimentar e ao desenvolvimento sustentável no município.",
    "atuacao": "MUNICIPAL",
    "ativo": "S",
    "dt_inicio": "15/01/2025",
    "dt_fim": null,
    "id_tipo_iniciativa": 10,
    "atividades": [
        {
            "id_atividade": 1
        },
        {
            "id_atividade": 3
        }
    ],
    "organizacoes": [
        {
            "id_organizacao": 4
        },
        {
            "id_organizacao": 7
        }
    ],
    "redes_sociais": [
        {
            "url_rede": "@agriculturaurbana",
            "id_tipo_rede": 1
        },
        {
            "url_rede": "https://www.facebook.com/agriculturaurbana",
            "id_tipo_rede": 2
        }
    ],
    "subcategorias": [
        {
            "id_subcategoria": 21
        },
        {
            "id_subcategoria": 22
        }
    ]
}
*/

CREATE OR REPLACE PROCEDURE PD_INICIATIVA_PUBLICA_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_REGISTRO OUT NUMBER, P_ID_ENTIDADE IN NUMBER, P_NOVO_CADASTRO IN BOOLEAN, P_ID_REGISTRO_ATUAL IN NUMBER DEFAULT NULL)
AS
    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON               JSON_OBJECT_T;
    V_DADOS_LOCALIZACAO  JSON_OBJECT_T;

    -- DADOS PARA TABELA 'INICIATIVAS_PUBLICAS'
    V_ID_INICIATIVA       AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.ID_INICIATIVA%TYPE;
    V_INICIATIVA          AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.INICIATIVA%TYPE;
    V_EMAIL               AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.EMAIL%TYPE;
    V_TELEFONE_1          AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.TELEFONE_1%TYPE;
    V_TELEFONE_2          AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.TELEFONE_2%TYPE;
    V_DESCRICAO           AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.DESCRICAO%TYPE;
    V_ATUACAO             AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.ATUACAO%TYPE;
    V_ATIVO               AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.ATIVO%TYPE;
    V_DT_INICIO           AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.DT_INICIO%TYPE;
    V_DT_FIM              AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.DT_FIM%TYPE;
    V_ID_TIPO_INICIATIVA  AGRICULTURA_URBANA_BAURU.INICIATIVAS_PUBLICAS.ID_TIPO_INICIATIVA%TYPE;

    -- DADOS PARA TABELA 'INICIATIVAS_PUBLICAS_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'INICIATIVAS_PUBLICAS_ORGANIZACOES'
    V_ORGANIZACOES       JSON_ARRAY_T;

    -- DADOS PARA TABELA 'INICIATIVAS_PUBLICAS_REDES_SOCIAIS'
    V_REDES_SOCIAIS      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'INICIATIVAS_PUBLICAS_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN

    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UMA NOVA INICIATIVA PÚBLICA
    IF P_NOVO_CADASTRO THEN

        -- TABELA INICIATIVAS_PUBLICAS --
        V_INICIATIVA         := V_JSON.GET_STRING('iniciativa');
        V_EMAIL              := V_JSON.GET_STRING('email');
        V_TELEFONE_1         := V_JSON.GET_NUMBER('telefone_1');
        V_TELEFONE_2         := V_JSON.GET_NUMBER('telefone_2');
        V_ATUACAO            := V_JSON.GET_STRING('atuacao');
        V_ATIVO              := V_JSON.GET_STRING('ativo');
        V_DT_INICIO          := TO_DATE(V_JSON.GET_STRING('dt_inicio') DEFAULT NULL ON CONVERSION ERROR,'DD/MM/YYYY');
        V_DT_FIM             := TO_DATE(V_JSON.GET_STRING('dt_fim') DEFAULT NULL ON CONVERSION ERROR,'DD/MM/YYYY');
        V_ID_TIPO_INICIATIVA := V_JSON.GET_NUMBER('id_tipo_iniciativa');

        IF V_INICIATIVA IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O NOME DA INICIATIVA PÚBLICA');
        END IF;

        IF V_EMAIL IS NOT NULL AND NOT REGEXP_LIKE(V_EMAIL,'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20003, 'INFORME UM EMAIL VÁLIDO');
        END IF;

        IF (V_TELEFONE_1 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_1, '^[1-9][0-9]{9,10}$')) OR (V_TELEFONE_2 IS NOT NULL AND NOT REGEXP_LIKE(V_TELEFONE_2, '^[1-9][0-9]{9,10}$')) THEN
            RAISE_APPLICATION_ERROR(-20004, 'INFORME TELEFONES VÁLIDOS');
        END IF;

        IF V_ATUACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME A ATUAÇÃO DA INICIATVA');
        END IF;

        IF LENGTHB(V_JSON.GET_STRING('descricao')) > 4000 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO MUITO LONGA');
        ELSE
            V_DESCRICAO := V_JSON.GET_STRING('descricao');
        END IF;

        IF V_ATIVO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O STATUS DA INICIATIVA');
        END IF;

        IF V_JSON.GET_STRING('dt_inicio') IS NOT NULL AND V_DT_INICIO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'DATA DE INÍCIO INVÁLIDA');
        END IF;

        IF V_JSON.GET_STRING('dt_fim') IS NOT NULL AND V_DT_FIM IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'DATA DE ENCERRAMENTO INVÁLIDA');
        END IF;

        IF (V_DT_INICIO IS NOT NULL AND V_DT_FIM IS NOT NULL) AND V_DT_FIM < V_DT_INICIO THEN
            RAISE_APPLICATION_ERROR(-20021, 'ENCERRAMENTO DA INICIATIVA NÃO PODE ANTECEDER A DATA DE INÍCIO');
        END IF;

        IF V_ID_TIPO_INICIATIVA IS NULL THEN
            RAISE_APPLICATION_ERROR(-20002, 'INFORME O TIPO DA INICIATIVA PÚBLICA');
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DO AGRICULTOR
        INSERT INTO INICIATIVAS_PUBLICAS (INICIATIVA, EMAIL, TELEFONE_1, TELEFONE_2, DESCRICAO, ATUACAO, ATIVO, DT_INICIO, DT_FIM, ID_TIPO_INICIATIVA)
        VALUES (V_INICIATIVA, V_EMAIL, V_TELEFONE_1, V_TELEFONE_2, V_DESCRICAO, V_ATUACAO, V_ATIVO, V_DT_INICIO, V_DT_FIM, V_ID_INICIATIVA)
        RETURNING ID_INICIATIVA INTO V_ID_INICIATIVA;

    -- FLUXO 2: INICIATIVA JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_INICIATIVA := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA INICIATIVAS_PUBLICAS_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'INICIATIVAS_PUBLICAS_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_INICIATIVA IDENTIFICA A INICIATIVA
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_ENTIDADE, V_ID_INICIATIVA);
    END IF;

    -- TABELA INICIATIVAS_PUBLICAS_ORGANIZACOES --
    V_ORGANIZACOES := V_JSON.GET_ARRAY('organizacoes');

    -- SE O ARRAY DE ORGANIZACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'INICIATIVAS_PUBLICAS_ORGANIZACOES'
    -- V_ORGANIZACOES CONTÉM AS ORGANIZACOES, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_INICIATIVA IDENTIFICA A INICIATIVA
    IF V_ORGANIZACOES IS NOT NULL THEN
        PD_ENTIDADE_ORGANIZACOES_INSERT(V_ORGANIZACOES, P_ID_ENTIDADE, V_ID_INICIATIVA);
    END IF;

    -- TABELA INICIATIVAS_PUBLICAS_REDES_SOCIAIS --
    V_REDES_SOCIAIS := V_JSON.GET_ARRAY('redes_sociais');

    -- SE O ARRAY DE REDES SOCIAIS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'INICIATIVAS_PUBLICAS_REDES_SOCIAIS'
    -- V_REDES_SOCIAIS CONTÉM AS REDES SOCIAIS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_INICIATIVA IDENTIFICA A INICIATIVA
    IF V_REDES_SOCIAIS IS NOT NULL THEN
        PD_ENTIDADE_REDES_SOCIAIS_INSERT(V_REDES_SOCIAIS, P_ID_ENTIDADE, V_ID_INICIATIVA);
    END IF;

    -- TABELA INICIATIVAS_PUBLICAS_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'INICIATIVAS_PUBLICAS_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_INICIATIVA IDENTIFICA A INICIATIVA
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_ENTIDADE, V_ID_INICIATIVA);
    END IF;

    P_ID_REGISTRO := V_ID_INICIATIVA;

END PD_INICIATIVAS_PUBLICAS_INSERT;



/* PROCEDURE PD_VIVENCIA_RURAL_INSERT
-> RESPONSÁVEL POR CADASTRAR UMA VIVÊNCIA_RURAL 
-> RECEBE COMO PARAMETRO OS DADOS PREENCHIDOS NO FRONT-END, ALÉM DO ID DA ENTIDADE A QUAL PERTENCE (AGRICULTOR OU HORTA)
-> FORMATO JSON: 
{
    "acessibilidade_pcd": "S",
    "estacionamento": "Estacionamento disponível para carros e ônibus de excursão.",
    "descricao": "Experiência de turismo rural com visita guiada à propriedade, contato com a natureza, apresentação das técnicas de cultivo e atividades educativas sobre agricultura sustentável.",
    "funcionamento": "Sábados e domingos, das 08h às 17h",
    "id_agricultor": 1,
    "id_horta": 1,
    "atividades": [
        {
            "id_atividade": 1
        },
        {
            "id_atividade": 3
        }
    ],
    "qualificacoes": [
        {
            "qualificacao": "Turismo rural sustentável",
            "dt_qualificacao": "10/08/2025",
            "id_tipo_qualificacao": 1,
            "certificado_base64": null
        },
        {
            "qualificacao": "Educação ambiental",
            "dt_qualificacao": "05/02/2026",
            "id_tipo_qualificacao": 2,
            "certificado_base64": null
        }
    ],
    "subcategorias": [
        {
            "id_subcategoria": 21
        },
        {
            "id_subcategoria": 22
        }
    ]
}

*/

CREATE OR REPLACE PROCEDURE PD_VIVENCIA_RURAL_INSERT
(P_DADOS_ENTIDADES IN CLOB, P_ID_ENTIDADE IN NUMBER, P_TIPO_ENTIDADE IN VARCHAR2, P_NOVO_CADASTRO IN BOOLEAN, P_ID_TIPO_ENTIDADE)
AS
    -- USAMOS O JSON_OBJECT_T PARA GUARDAR TODA A ESTRUTURA JSON RECEBIDA
    V_JSON               JSON_OBJECT_T;

    -- DADOS PARA TABELA 'VIVENCIA_RURAL'
    V_ID_VIVENCIA_RURAL  AGRICULTURA_URBANA_BAURU.VIVENCIA_RURAL.ID_VIVENCIA_RURAL%TYPE;
    V_ACESSIBILIDADE_PCD AGRICULTURA_URBANA_BAURU.VIVENCIA_RURAL.ACESSIBILIDADE_PCD%TYPE;
    V_ESTACIONAMENTO     AGRICULTURA_URBANA_BAURU.VIVENCIA_RURAL.ESTACIONAMENTO%TYPE;
    V_DESCRICAO          AGRICULTURA_URBANA_BAURU.VIVENCIA_RURAL.DESCRICAO%TYPE;
    V_FUNCIONAMENTO      AGRICULTURA_URBANA_BAURU.VIVENCIA_RURAL.FUNCIONAMENTO%TYPE;

    -- DADOS PARA TABELA 'VIVENCIA_RURAL_ATIVIDADES'
    V_ATIVIDADES         JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_QUALIFICACOES'
    V_QUALIFICACOES      JSON_ARRAY_T;

    -- DADOS PARA TABELA 'AGRICULTORES_SUBCATEGORIAS'
    V_SUBCATEGORIAS      JSON_ARRAY_T;

BEGIN

    IF P_NOVO_CADASTRO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'TIPO DE CADASTRO INVÁLIDO');
    END IF;

    -- PASSAMOS O CONTEUDO DOS DADOS RECEBIDOS PARA A VARIAVEL 'V_JSON'
    V_JSON := JSON_OBJECT_T.PARSE(P_DADOS_ENTIDADES);

    -- FLUXO 1: SE FOR UMA NOVA VIVENCIA RURAL
    IF P_NOVO_CADASTRO THEN

        -- TABELA VIVENCIA RURAL --
        V_ACESSIBILIDADE_PCD := V_JSON.GET_STRING('acessibilidade_pcd');
        V_ESTACIONAMENTO     := V_JSON.GET_STRING('estacionamento');
        V_FUNCIONAMENTO      := V_JSON.GET_STRING('funcionamento');

        IF LENGTHB(V_JSON.GET_STRING('descricao')) > 4000 THEN
            RAISE_APPLICATION_ERROR(-20005, 'DESCRIÇÃO MUITO LONGA');
        ELSE
            V_DESCRICAO := V_JSON.GET_STRING('descricao');
        END IF;

        -- SE NENHUM IF ACIMA FOR DISPARADO, ENTÃO FAZ O INSERT DA VIVENCIA
        IF(P_TIPO_ENTIDADE = 'AGRICULTOR') THEN
            INSERT INTO VIVENCIA_RURAL (ACESSIBILIDADE_PCD, ESTACIONAMENTO, DESCRICAO, FUNCIONAMENTO, ID_AGRICULTOR, ID_HORTA)
            VALUES (V_ACESSIBILIDADE_PCD, V_ESTACIONAMENTO, V_DESCRICAO, V_FUNCIONAMENTO, P_ID_ENTIDADE, NULL)
            RETURNING ID_VIVENCIA_RURAL INTO V_ID_VIVENCIA_RURAL;
        ELSE
            INSERT INTO VIVENCIA_RURAL (ACESSIBILIDADE_PCD, ESTACIONAMENTO, DESCRICAO, FUNCIONAMENTO, ID_AGRICULTOR, ID_HORTA)
            VALUES (V_ACESSIBILIDADE_PCD, V_ESTACIONAMENTO, V_DESCRICAO, V_FUNCIONAMENTO, NULL, P_ID_ENTIDADE)
            RETURNING ID_VIVENCIA_RURAL INTO V_ID_VIVENCIA_RURAL;
        END IF;

    -- FLUXO 2: VIVENCIA RURAL JÁ TEM CADASTRO, SÓ VAI CADASTRAR UMA NOVA ENTIDADE
    ELSE
        V_ID_VIVENCIA_RURAL := P_ID_REGISTRO_ATUAL;

    END IF;

    -- TABELA VIVENCIA_RURAL_ATIVIDADES --
    V_ATIVIDADES := V_JSON.GET_ARRAY('atividades');

    -- SE O ARRAY DE ATIVIDADES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'VIVENCIA_RURAL_ATIVIDADES'
    -- V_ATIVIDADES CONTÉM AS ATIVIDADES, P_ID_TIPO_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_VIVENCIA IDENTIFICA A VIVENCIA RURAL
    IF V_ATIVIDADES IS NOT NULL THEN
        PD_ENTIDADE_ATIVIDADES_INSERT(V_ATIVIDADES, P_ID_TIPO_ENTIDADE, V_ID_VIVENCIA_RURAL);
    END IF;

    -- TABELA VIVENCIA_RURAL_QUALIFICACOES --
    V_QUALIFICACOES := V_JSON.GET_ARRAY('qualificacoes');

    -- SE O ARRAY DE QUALIFICACOES NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'VIVENCIA_RURAL_QUALIFICACOES'
    -- V_QUALIFICACOES CONTÉM AS QUALIFICAÇÕES, P_ID_TIPO_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_VIVENCIA IDENTIFICA A VIVENCIA RURAL
    IF V_QUALIFICACOES IS NOT NULL THEN
        PD_ENTIDADE_QUALIFICACOES_INSERT(V_QUALIFICACOES, P_ID_TIPO_ENTIDADE, V_ID_VIVENCIA_RURAL);
    END IF;

    -- TABELA VIVENCIA_RURAL_SUBCATEGORIAS --
    V_SUBCATEGORIAS := V_JSON.GET_ARRAY('subcategorias');

    -- SE O ARRAY DE SUBCATEGORIAS NÃO ESTIVER VAZIO, CHAMA A PROCEDURE DE INSERT PARA 'VIVENCIA_RURAL_SUBCATEGORIAS'
    -- V_SUBCATEGORIAS CONTÉM AS SUBCATEGORIAS, P_ID_TIPO_ENTIDADE IDENTIFICA A ENTIDADE, V_ID_VIVENCIA IDENTIFICA A VIVENCIA RURAL
    IF V_SUBCATEGORIAS IS NOT NULL THEN
        PD_ENTIDADE_SUBCATEGORIAS_INSERT(V_SUBCATEGORIAS, P_ID_TIPO_ENTIDADE, V_ID_VIVENCIA_RURAL);
    END IF;

    --P_ID_REGISTRO := V_ID_VIVENCIA_RURAL;

END PD_VIVENCIA_RURAL_INSERT;


/* PROCEDURE PD_LOCALIZACOES_INSERT
-> FAZ O INSERT NA TABELA 'LOCALIZACOES'
-> RECEBE COMO PARAMETROS UM JSON CONTENDO AS INFORMAÇÕES DE LOCALIZACOES DA ENTIDADE
-> E UM ID_ZONA ESCOLHIDO NO FRONT END 
-> ESTRUTURA DO JSON:

    {
        "endereco": "",
        "bairro": "",
        "distrito": "",
        "cep": "",
        "latitude": "",
        "longitude": "",
        "id_zona": "",
        "municipio": "",
        "uf": ""    
    }
*/

CREATE OR REPLACE PROCEDURE PD_LOCALIZACOES_INSERT
(P_DADOS_LOCALIZACAO IN CLOB, P_ID_LOCAL OUT NUMBER)
AS
    V_JSON        JSON_OBJECT_T;
    V_ENDERECO    AGRICULTURA_URBANA_BAURU.LOCALIZACOES.ENDERECO%TYPE;
    V_BAIRRO      AGRICULTURA_URBANA_BAURU.LOCALIZACOES.BAIRRO%TYPE;
    V_DISTRITO    AGRICULTURA_URBANA_BAURU.LOCALIZACOES.DISTRITO%TYPE;
    V_CEP         AGRICULTURA_URBANA_BAURU.LOCALIZACOES.CEP%TYPE;
    V_LATITUDE    AGRICULTURA_URBANA_BAURU.LOCALIZACOES.LATITUDE%TYPE;
    V_LONGITUDE   AGRICULTURA_URBANA_BAURU.LOCALIZACOES.LONGITUDE%TYPE;
    V_COORDENADAS AGRICULTURA_URBANA_BAURU.LOCALIZACOES.COORDENADAS%TYPE;
    V_ID_ZONA     AGRICULTURA_URBANA_BAURU.LOCALIZACOES.ID_ZONA%TYPE;
    V_MUNICIPIO   AGRICULTURA_URBANA_BAURU.LOCALIZACOES.MUNICIPIO%TYPE;
    V_UF          AGRICULTURA_URBANA_BAURU.LOCALIZACOES.UF%TYPE;

    -- AUXILIARES
    V_LATITUDE_NUM  NUMBER;
    V_LONGITUDE_NUM NUMBER;
    V_CEP_ENTRADA   VARCHAR2(30);

BEGIN
    V_JSON         := JSON_OBJECT_T.PARSE(P_DADOS_LOCALIZACAO);
    V_ENDERECO     := V_JSON.GET_STRING('endereco');
    V_BAIRRO       := V_JSON.GET_STRING('bairro');
    V_DISTRITO     := V_JSON.GET_STRING('distrito');
    V_CEP_ENTRADA  := V_JSON.GET_STRING('cep');
    V_LATITUDE     := V_JSON.GET_STRING('latitude');
    V_LONGITUDE    := V_JSON.GET_STRING('longitude');
    V_ID_ZONA      := V_JSON.GET_NUMBER('id_zona');
    V_MUNICIPIO    := V_JSON.GET_STRING('municipio');
    V_UF           := V_JSON.GET_STRING('uf');

    IF V_ENDERECO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20013, 'INFORME O ENDEREÇO PRINCIPAL DA ÁREA');
    END IF;

    IF V_CEP_ENTRADA IS NOT NULL AND NOT REGEXP_LIKE(V_CEP_ENTRADA, '^[0-9]{8}$') THEN
        RAISE_APPLICATION_ERROR(-20014, 'INFORME UM CEP VÁLIDO DA ÁREA');
    ELSE
        V_CEP := TO_NUMBER(V_CEP_ENTRADA);
    END IF;

    IF (V_LATITUDE IS NOT NULL AND NOT REGEXP_LIKE(V_LATITUDE, '^-?[0-9]+([.,][0-9]+)?$')) OR (V_LONGITUDE IS NOT NULL AND NOT REGEXP_LIKE(V_LONGITUDE, '^-?[0-9]+([.,][0-9]+)?$')) THEN
        RAISE_APPLICATION_ERROR(-20015, 'LATITUDE E LONGITUDE SÓ PODEM SER NÚMEROS');
    END IF;

    IF V_LATITUDE IS NOT NULL AND V_LONGITUDE IS NOT NULL THEN
        V_LATITUDE_NUM := TO_NUMBER(REPLACE(V_LATITUDE, ',', '.'),'999999999999999D999999999999999','NLS_NUMERIC_CHARACTERS=''.,''');
        V_LONGITUDE_NUM := TO_NUMBER(REPLACE(V_LONGITUDE, ',', '.'),'999999999999999D999999999999999','NLS_NUMERIC_CHARACTERS=''.,''');
        IF (V_LATITUDE_NUM NOT BETWEEN -90 AND 90) OR (V_LONGITUDE_NUM NOT BETWEEN -180 AND 180) THEN
            RAISE_APPLICATION_ERROR(-20016, 'LATITUDE OU LONGITUDE FORA DO INTERVALO PERMITIDO');
        ELSE
            V_COORDENADAS := SDO_GEOMETRY(2001,4326,SDO_POINT_TYPE(V_LONGITUDE_NUM,V_LATITUDE_NUM, NULL),NULL,NULL);
        END IF;
    ELSE
        V_COORDENADAS := NULL;
    END IF;

    IF (V_LATITUDE IS NULL AND V_LONGITUDE IS NOT NULL) OR (V_LATITUDE IS NOT NULL AND V_LONGITUDE IS NULL) THEN
        RAISE_APPLICATION_ERROR(-20017, 'LATITUDE E LONGITUDE DEVEM SER INFORMADOS');
    END IF;

    IF V_ID_ZONA IS NULL OR V_ID_ZONA <=0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'UMA ZONA VÁLIDA DEVE SER INFORMADA');
    END IF;

    IF V_MUNICIPIO IS NULL OR (V_MUNICIPIO IS NOT NULL AND NOT REGEXP_LIKE(V_MUNICIPIO, '^[[:alpha:] ]+$')) THEN
        RAISE_APPLICATION_ERROR(-20019, 'UM MUNICÍPIO VÁLIDO DEVE SER INFORMADO');
    END IF;

    IF V_UF IS NULL OR V_UF <> 'SP' THEN
        RAISE_APPLICATION_ERROR(-20020, 'UF VÁLIDO DEVE SER SÃO PAULO (SP)');
    END IF;

    -- SE NENHUM IF FOR DISPARADO, ENTÃO FAZ O INSERT DA LOCALIZAÇÃO
    INSERT INTO LOCALIZACOES (ENDERECO, BAIRRO, DISTRITO, CEP, LATITUDE, LONGITUDE, COORDENADAS, ID_ZONA, MUNICIPIO, UF)
    VALUES (V_ENDERECO, V_BAIRRO, V_DISTRITO, V_CEP, V_LATITUDE, V_LONGITUDE, V_COORDENADAS, V_ID_ZONA, UPPER(V_MUNICIPIO), UPPER(V_UF))
    RETURNING ID_LOCAL INTO P_ID_LOCAL;

END PD_LOCALIZACOES_INSERT;


/* PROCEDURE PD_ENTIDADE_ATIVIDADES_INSERT
-> FAZ O INSERT DAS ATIVIDADES DE UMA ENTIDADE ESPECÍFICA
-> RECEBE COMO PARÂMETRO A LISTA DE ID_ATIVIDADES, O ID_ENTIDADE QUE IDENTIFICA A ENTIDADE E O ID_REGISTRO QUE IDENTIFICA QUAL REGISTRO DA ENTIDADE VAI RECEBER O INSERT
-> ESTRUTURA DO JSON RECEBIDO
{
    "atividades": [
        {"id_atividade": 1},
        {"id_atividade": 3}
    ]
}
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_ATIVIDADES_INSERT
(P_ENTIDADE_ATIVIDADES IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_ID_ATIVIDADE AGRICULTURA_URBANA_BAURU.ATIVIDADES.ID_ATIVIDADE%TYPE;
    V_ATIVIDADES  JSON_OBJECT_T;
BEGIN

    -- PERCORRE AS ATIVIDADES INFORMADAS NO ARRAY
    FOR I IN 0 .. P_ENTIDADE_ATIVIDADES.GET_SIZE() - 1 LOOP
        V_ATIVIDADES := TREAT(P_ENTIDADE_ATIVIDADES.GET(I) AS JSON_OBJECT_T);
        V_ID_ATIVIDADE := V_ATIVIDADES.GET_NUMBER('id_atividade');

        -- DE ACORDO COM P_ID_ENTIDADE, A TABELA PARA ENTIDADE É ESCOLHIDA
        
        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_ATIVIDADES (ID_AGRICULTOR, ID_ATIVIDADE)
            VALUES (P_ID_REGISTRO, V_ID_ATIVIDADE);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_ATIVIDADES (ID_HORTA, ID_ATIVIDADE)
            VALUES (P_ID_REGISTRO, V_ID_ATIVIDADE);
        END IF;

        -- FEIRAS MUNICIPAIS
        IF P_ID_ENTIDADE = 3 THEN
            INSERT INTO FEIRAS_MUNICIPAS_ATIVIDADES (ID_FEIRA, ID_ATIVIDADE)
            VALUES (P_ID_REGISTRO, V_ID_ATIVIDADE);
        END IF;

        -- ATRATIVOS TURISTICOS
        IF P_ID_ENTIDADE = 4 THEN
            INSERT INTO ATRATIVOS_TURISTICOS_ATIVIDADES (ID_ATRATIVO, ID_ATIVIDADE)
            VALUES (P_ID_REGISTRO, V_ID_ATIVIDADE);
        END IF;

        -- SERVIÇOS AGRICULTURA
        IF P_ID_ENTIDADE = 5 THEN
            INSERT INTO SERVICOS_AGRICULTURA_ATIVIDADES (ID_SERVICO, ID_ATIVIDADE)
            VALUES (P_ID_REGISTRO, V_ID_ATIVIDADE);
        END IF;

        -- INICIATIVAS PUBLICAS
        IF P_ID_ENTIDADE = 6 THEN
            INSERT INTO INICIATIVAS_PUBLICAS_ATIVIDADES (ID_INICIATIVA, ID_ATIVIDADE)
            VALUES (P_ID_REGISTRO, V_ID_ATIVIDADE);
        END IF;

    END LOOP;
END PD_ENTIDADE_ATIVIDADES_INSERT



/* PROCEDURE PD_ENTIDADE_CERTIFICACOES_INSERT
-> FAZ O INSERT DA TABELA DE CERTIFICACOES DE UMA ENTIDADE
-> RECEBE COMO PARAMETRO O ARRAY "CERTIFICACOES" CADASTRADAS NO FRONT
-> RECEBE TAMBÉM O ID_ENTIDADE PARA IDENTIFICAR A ENTIDADE E O ID_REGISTRO PARA QUAL REGISTRO O INSERT DEVE OCORRER
-> "certificacoes": [
    {
        "id_certificacao": 2,
        "dt_certificado": "15-01-2026",
        "dt_vencimento": "2027-01-15",
        "certificado_base64": null
    },
    {
        "id_certificacao": 5,
        "dt_certificado": "03-02-2027",
        "dt_vencimento": null,
        "certificado_base64": null
    }
]
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_CERTIFICACOES_INSERT
(P_ENTIDADE_CERTIFICACOES IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_ID_CERTIFICACAO   AGRICULTURA_URBANA_BAURU.CERTIFICACOES.ID_CERTIFICACAO%TYPE;
    V_CERTIFICACOES     JSON_OBJECT_T;
    V_DT_CERTIFICADO    DATE;
    V_DT_VENCIMENTO     DATE;
    V_CERTIFICADO       BLOB;

    -- AUXILIARES
    V_CERTIFICADO_BASE64 CLOB;

BEGIN
    -- PERCORRE AS CERTIFICACOES ENVIADAS
    FOR I IN 0 .. P_ENTIDADE_CERTIFICACOES.GET_SIZE() - 1 LOOP

        V_CERTIFICACOES := TREAT(P_ENTIDADE_CERTIFICACOES.GET(I) AS JSON_OBJECT_T);
        V_ID_CERTIFICACAO := V_CERTIFICACOES.GET_NUMBER('id_certificacao');
        V_DT_CERTIFICADO := TO_DATE(V_CERTIFICACOES.GET_STRING('dt_certificado') DEFAULT NULL ON CONVERSION ERROR,'DD/MM/YYYY');
        V_DT_VENCIMENTO := TO_DATE(V_CERTIFICACOES.GET_STRING('dt_vencimento') DEFAULT NULL ON CONVERSION ERROR,'DD/MM/YYYY');
        V_CERTIFICADO_BASE64 := V_CERTIFICACOES.GET_CLOB('certificado_base64');
        V_CERTIFICADO := NULL;

        IF V_ID_CERTIFICACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'CERTIFICAÇÃO DEVE SER INFORMADA');
        END IF; 

        IF V_CERTIFICACOES.GET_STRING('dt_certificado') IS NOT NULL AND V_DT_CERTIFICADO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'DATA DE CERTIFICAÇÃO É INVÁLIDA');
        END IF;

        IF V_CERTIFICACOES.GET_STRING('dt_vencimento') IS NOT NULL AND V_DT_VENCIMENTO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'DATA DE VENCIMENTO DA CERTIFICAÇÃO É INVÁLIDA');
        END IF;

        IF (V_DT_CERTIFICADO IS NOT NULL AND V_DT_VENCIMENTO IS NOT NULL) AND V_DT_VENCIMENTO < V_DT_CERTIFICADO THEN
            RAISE_APPLICATION_ERROR(-20021, 'VENCIMENTO DA CERTIFICAÇÃO NÃO PODE ANTECEDER A DATA DA CERTIFICAÇÃO');
        END IF;

        IF V_CERTIFICADO_BASE64 IS NOT NULL THEN
            V_CERTIFICADO := FC_CONVERTER_BASE64_TO_BLOB(V_CERTIFICADO_BASE64);
        END IF;

        -- SE NENHUM IF ACIMA FOR ACIONADO, ENTÃO FAZEMOS O INSERT NA TABELA DA ENTIDADE_CERTIFICACOES

        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_CERTIFICACOES (ID_AGRICULTOR, ID_CERTIFICACAO, DT_CERTIFICADO, DT_VENCIMENTO, CERTIFICADO)
            VALUES (P_ID_REGISTRO, V_ID_CERTIFICACAO, V_DT_CERTIFICADO, V_DT_VENCIMENTO, V_CERTIFICADO);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_CERTIFICACOES (ID_HORTA, ID_CERTIFICACAO, DT_CERTIFICADO, DT_VENCIMENTO, CERTIFICADO)
            VALUES (P_ID_REGISTRO, V_ID_CERTIFICACAO, V_DT_CERTIFICADO, V_DT_VENCIMENTO, V_CERTIFICADO);
        END IF;

        -- FEIRAS MUNICIPAIS
        IF P_ID_ENTIDADE = 3 THEN
            INSERT INTO FEIRAS_MUNICIPAIS_CERTIFICACOES (ID_FEIRA, ID_CERTIFICACAO, DT_CERTIFICADO, DT_VENCIMENTO, CERTIFICADO)
            VALUES (P_ID_REGISTRO, V_ID_CERTIFICACAO, V_DT_CERTIFICADO, V_DT_VENCIMENTO, V_CERTIFICADO);
        END IF;

        -- ATRATIVOS TURISTICOS
        IF P_ID_ENTIDADE = 4 THEN
            INSERT INTO ATRATIVOS_TURISTICOS_CERTIFICACOES (ID_ATRATIVO, ID_CERTIFICACAO, DT_CERTIFICADO, DT_VENCIMENTO, CERTIFICADO)
            VALUES (P_ID_REGISTRO, V_ID_CERTIFICACAO, V_DT_CERTIFICADO, V_DT_VENCIMENTO, V_CERTIFICADO);
        END IF;

        -- SERVIÇOS AGRICULTURA
        IF P_ID_ENTIDADE = 5 THEN
            INSERT INTO SERVICOS_AGRICULTURA_CERTIFICACOES (ID_SERVICO, ID_CERTIFICACAO, DT_CERTIFICADO, DT_VENCIMENTO, CERTIFICADO)
            VALUES (P_ID_REGISTRO, V_ID_CERTIFICACAO, V_DT_CERTIFICADO, V_DT_VENCIMENTO, V_CERTIFICADO);
        END IF;

    END LOOP;
END PD_ENTIDADE_CERTIFICACOES_INSERT;



/* PROCEDURE PD_ENTIDADE_ORGANIZACOES_INSERT
-> FAZ O INSERT DA TABELA DE ORGANIZACOES DE UMA ENTIDADE
-> RECEBE COMO PARAMETRO O ARRAY "ORGANIZACOES" CADASTRADAS NO FRONT
-> RECEBE TAMBÉM O ID_ENTIDADE PARA IDENTIFICAR A ENTIDADE E O ID_REGISTRO PARA QUAL REGISTRO O INSERT DEVE OCORRER
-> "organizacoes": [
        {
            "id_organizacao": 4
        },
        {
            "id_organizacao": 7
        }
    ]
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_ORGANIZACOES_INSERT
(P_ENTIDADE_ORGANIZACOES IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_ID_ORGANIZACAO AGRICULTURA_URBANA_BAURU.ORGANIZACOES.ID_ORGANIZACAO%TYPE;
    V_ORGANIZACOES JSON_OBJECT_T;
BEGIN
    -- PERCORRE AS ORGANIZACOES INFORMADAS NO ARRAY
    FOR I IN 0 .. P_ENTIDADE_ORGANIZACOES.GET_SIZE() - 1 LOOP
        V_ORGANIZACOES := TREAT(P_ENTIDADE_ORGANIZACOES.GET(I) AS JSON_OBJECT_T);
        V_ID_ORGANIZACAO := V_ORGANIZACOES.GET_NUMBER('id_organizacao');

        -- DE ACORDO COM P_ID_ENTIDADE, A TABELA PARA ENTIDADE É ESCOLHIDA
        
        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_ORGANIZACOES (ID_AGRICULTOR, ID_ORGANIZACAO)
            VALUES (P_ID_REGISTRO, V_ID_ORGANIZACAO);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_ORGANIZACOES (ID_HORTA, ID_ORGANIZACAO)
            VALUES (P_ID_REGISTRO, V_ID_ORGANIZACAO);
        END IF;

        -- FEIRAS MUNICIPAIS
        IF P_ID_ENTIDADE = 3 THEN
            INSERT INTO FEIRAS_MUNICIPAIS_ORGANIZACOES (ID_FEIRA, ID_ORGANIZACAO)
            VALUES (P_ID_REGISTRO, V_ID_ORGANIZACAO);
        END IF;

        -- ATRATIVOS TURISTICOS
        IF P_ID_ENTIDADE = 4 THEN
            INSERT INTO ATRATIVOS_TURISTICOS_ORGANIZACOES (ID_ATRATIVO, ID_ORGANIZACAO)
            VALUES (P_ID_REGISTRO, V_ID_ORGANIZACAO);
        END IF;

        -- SERVICOS AGRICULTURA
        IF P_ID_ENTIDADE = 5 THEN
            INSERT INTO SERVICOS_AGRICULTURA_ORGANIZACOES (ID_SERVICO, ID_ORGANIZACAO)
            VALUES (P_ID_REGISTRO, V_ID_ORGANIZACAO);
        END IF;

        -- INICIATIVAS PUBLICAS
        IF P_ID_ENTIDADE = 6 THEN
            INSERT INTO INICIATIVAS_PUBLICAS_ORGANIZACOES (ID_INICIATIVA, ID_ORGANIZACAO)
            VALUES (P_ID_REGISTRO, V_ID_ORGANIZACAO);
        END IF;

    END LOOP;
END PD_ENTIDADE_ORGANIZACOES_INSERT;



/* PROCEDURE PD_ENTIDADE_PONTOS_VENDA_INSERT
-> FAZ O INSERT DA TABELA DE PONTOS DE VENDA DE UMA ENTIDADE
-> RECEBE COMO PARAMETRO O ARRAY "PONTOS_VENDA" CADASTRADAS NO FRONT
-> RECEBE TAMBÉM O ID_ENTIDADE PARA IDENTIFICAR A ENTIDADE E O ID_REGISTRO PARA QUAL REGISTRO O INSERT DEVE OCORRER
-> "pontos_venda": [
        {
            "id_ponto": 10
        },
        {
            "id_ponto": 12
        }
    ]
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_PONTOS_VENDA_INSERT
(P_ENTIDADE_PONTOS_VENDA IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_ID_PONTO_VENDA AGRICULTURA_URBANA_BAURU.PONTOS_VENDA.ID_PONTO%TYPE;
    V_PONTOS_VENDA JSON_OBJECT_T;
BEGIN
    -- PERCORRE OS PONTOS DE VENDA INFORMADOS NO ARRAY
    FOR I IN 0 .. P_ENTIDADE_PONTOS_VENDA.GET_SIZE() - 1 LOOP
        V_PONTOS_VENDA := TREAT(P_ENTIDADE_PONTOS_VENDA.GET(I) AS JSON_OBJECT_T);
        V_ID_PONTO_VENDA := V_PONTOS_VENDA.GET_NUMBER('id_ponto');

        -- DE ACORDO COM P_ID_ENTIDADE, A TABELA PARA ENTIDADE É ESCOLHIDA
        
        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_PONTOS_VENDA (ID_AGRICULTOR, ID_PONTO)
            VALUES (P_ID_REGISTRO, V_ID_PONTO_VENDA);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_PONTOS_VENDA (ID_HORTA, ID_PONTO_VENDA)
            VALUES (P_ID_REGISTRO, V_ID_PONTO_VENDA);
        END IF;

    END LOOP;
END PD_ENTIDADE_PONTOS_VENDA_INSERT;



/* PROCEDURE PD_ENTIDADE_QUALIFICACOES_INSERT
-> FAZ O INSERT DA TABELA DE QUALIFICAÇÕES DE UMA ENTIDADE
-> RECEBE COMO PARAMETRO O ARRAY "QUALIFICACOES" CADASTRADAS NO FRONT
-> RECEBE TAMBÉM O ID_ENTIDADE PARA IDENTIFICAR A ENTIDADE E O ID_REGISTRO PARA QUAL REGISTRO O INSERT DEVE OCORRER
-> "qualificacoes": [
        {
            "qualificacao": "Curso de Agricultura Orgânica",
            "dt_qualificacao": "08-10-2025",
            "id_tipo_qualificacao": 1,
            "certificado_base64": null
        },
        {
            "qualificacao": "Manejo Sustentável do Solo",
            "dt_qualificacao": "02-05-2026",
            "id_tipo_qualificacao": 2,
            "certificado_base64": null
        }
    ]
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_QUALIFICACOES_INSERT
(P_ENTIDADE_QUALIFICACOES IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_QUALIFICACOES        JSON_OBJECT_T;
    V_QUALIFICACAO         VARCHAR2(480);
    V_DT_QUALIFICACAO      DATE;
    V_ID_TIPO_QUALIFICACAO AGRICULTURA_URBANA_BAURU.QUALIFICACOES_TIPOS.ID_TIPO%TYPE;
    V_CERTIFICADO          BLOB;

    -- AUXILIARES
    V_CERTIFICADO_BASE64   CLOB;

BEGIN
    -- PERCORRE AS QUALIFICAÇÕES INFORMADAS NO ARRAY
    FOR I IN 0 .. P_ENTIDADE_QUALIFICACOES.GET_SIZE() - 1 LOOP
        V_QUALIFICACOES := TREAT(P_ENTIDADE_QUALIFICACOES.GET(I) AS JSON_OBJECT_T);
        V_QUALIFICACAO := V_QUALIFICACOES.GET_STRING('qualificacao');
        V_DT_QUALIFICACAO := TO_DATE(V_QUALIFICACOES.GET_STRING('dt_qualificacao') DEFAULT NULL ON CONVERSION ERROR,'DD/MM/YYYY');
        V_ID_TIPO_QUALIFICACAO := V_QUALIFICACOES.GET_NUMBER('id_tipo_qualificacao');
        V_CERTIFICADO_BASE64 := V_QUALIFICACOES.GET_CLOB('certificado_base64');
        V_CERTIFICADO := NULL;

        IF V_QUALIFICACAO IS NULL OR NOT REGEXP_LIKE(V_QUALIFICACAO, '^[[:alnum:] .-]+$') THEN
            RAISE_APPLICATION_ERROR(-20021, 'INFORME UM NOME DE QUALIFICAÇÃO VÁLIDO');
        END IF;

        IF V_QUALIFICACOES.GET_STRING('dt_qualificacao') IS NOT NULL AND V_DT_QUALIFICACAO IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'DATA DA QUALIFICAÇÃO É INVÁLIDA');
        END IF;

        IF V_CERTIFICADO_BASE64 IS NOT NULL THEN
            V_CERTIFICADO := FC_CONVERTER_BASE64_TO_BLOB(V_CERTIFICADO_BASE64);
        END IF;

        -- DE ACORDO COM P_ID_ENTIDADE, A TABELA PARA ENTIDADE É ESCOLHIDA
        
        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_QUALIFICACOES (ID_AGRICULTOR, QUALIFICACAO, DT_QUALIFICACAO, CERTIFICADO, ID_TIPO_QUALIFICACAO)
            VALUES (P_ID_REGISTRO, UPPER(V_QUALIFICACAO), V_DT_QUALIFICACAO, V_CERTIFICADO, V_ID_TIPO_QUALIFICACAO);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_QUALIFICACOES (ID_HORTA, QUALIFICACAO, DT_QUALIFICACAO, CERTIFICADO, ID_TIPO_QUALIFICACAO)
            VALUES (P_ID_REGISTRO, UPPER(V_QUALIFICACAO), V_DT_QUALIFICACAO, V_CERTIFICADO, V_ID_TIPO_QUALIFICACAO);
        END IF;

        -- ATRATIVOS TURISTICOS
        IF P_ID_ENTIDADE = 4 THEN
            INSERT INTO ATRATIVOS_TURISTICOS_QUALIFICACOES (ID_ATRATIVO, QUALIFICACAO, DT_QUALIFICACAO, CERTIFICADO, ID_TIPO_QUALIFICACAO)
            VALUES (P_ID_REGISTRO, UPPER(V_QUALIFICACAO), V_DT_QUALIFICACAO, V_CERTIFICADO, V_ID_TIPO_QUALIFICACAO);
        END IF;

        -- SERVICOS AGRICULTURA
        IF P_ID_ENTIDADE = 5 THEN
            INSERT INTO SERVICOS_AGRICULTURA_QUALIFICACOES (ID_SERVICO, QUALIFICACAO, DT_QUALIFICACAO, CERTIFICADO, ID_TIPO_QUALIFICACAO)
            VALUES (P_ID_REGISTRO, UPPER(V_QUALIFICACAO), V_DT_QUALIFICACAO, V_CERTIFICADO, V_ID_TIPO_QUALIFICACAO);
        END IF;

    END LOOP;
END PD_ENTIDADE_QUALIFICACOES_INSERT;



/* PROCEDURE PD_ENTIDADE_REDES_SOCIAIS_INSERT
-> FAZ O INSERT DA TABELA DE REDES SOCIAIS DE UMA ENTIDADE
-> RECEBE COMO PARAMETRO O ARRAY "REDES_SOCIAIS" CADASTRADAS NO FRONT
-> RECEBE TAMBÉM O ID_ENTIDADE PARA IDENTIFICAR A ENTIDADE E O ID_REGISTRO PARA QUAL REGISTRO O INSERT DEVE OCORRER
-> "redes_sociais": [
        {
            "url_rede": "",
            "id_tipo_rede": ""
        },
        {
            "url_rede": "",
            "id_tipo_rede": ""
        }
    ]
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_REDES_SOCIAIS_INSERT
(P_ENTIDADE_REDES_SOCIAIS IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_REDES_SOCIAIS        JSON_OBJECT_T;
    V_URL_REDE         VARCHAR2(480);
    V_ID_TIPO_REDE AGRICULTURA_URBANA_BAURU.REDES_SOCIAIS.ID_TIPO%TYPE;
    V_ID_REDE_SOCIAL AGRICULTURA_URBANA_BAURU.REDES_SOCIAIS.ID_REDE_SOCIAL%TYPE;

    -- AUXILIARES
    V_EXISTE NUMBER;

BEGIN
    -- PERCORRE AS REDES SOCIAIS INFORMADAS NO ARRAY
    FOR I IN 0 .. P_ENTIDADE_REDES_SOCIAIS.GET_SIZE() - 1 LOOP
        V_REDES_SOCIAIS := TREAT(P_ENTIDADE_REDES_SOCIAIS.GET(I) AS JSON_OBJECT_T);
        V_URL_REDE := V_REDES_SOCIAIS.GET_STRING('url_rede');
        V_ID_TIPO_REDE := V_REDES_SOCIAIS.GET_NUMBER('id_tipo_rede');
        V_EXISTE := 0;

        IF V_URL_REDE IS NULL THEN
            RAISE_APPLICATION_ERROR(-20021, 'INFORME A URL DA SUA REDE SOCIAL');
        ELSE
            -- VERIFICA SE O URL_REDE INFORMADO JÁ EXISTE NA TABELA 'REDES_SOCIAIS'
            SELECT COUNT(*) INTO V_EXISTE FROM REDES_SOCIAIS WHERE URL_REDE = V_URL_REDE;

            -- EXISTE
            IF V_EXISTE > 0 THEN
                RAISE_APPLICATION_ERROR(-20021, 'REDE SOCIAL JÁ CADASTRADA NO SISTEMA');
            ELSE
                -- NÃO EXISTE, FAZ O INSERT DA NOVA REDE EM 'REDES_SOCIAIS'
                INSERT INTO REDES_SOCIAIS (ID_TIPO, URL_REDE)
                VALUES (V_ID_TIPO_REDE, V_URL_REDE)
                RETURNING ID_REDE_SOCIAL INTO V_ID_REDE_SOCIAL
            END IF;
        END IF;

        -- DE ACORDO COM P_ID_ENTIDADE, A TABELA PARA ENTIDADE É ESCOLHIDA
        
        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_REDES_SOCIAIS (ID_AGRICULTOR, ID_REDE_SOCIAL)
            VALUES (P_ID_REGISTRO, V_ID_REDE_SOCIAL);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_REDES_SOCIAIS (ID_HORTA, ID_REDE_SOCIAL)
            VALUES (P_ID_REGISTRO, V_ID_REDE_SOCIAL);
        END IF;

        -- FEIRAS MUNICIPAIS
        IF P_ID_ENTIDADE = 3 THEN
            INSERT INTO FEIRAS_MUNICIPAIS_REDES_SOCIAIS (ID_FEIRA, ID_REDE_SOCIAL)
            VALUES (P_ID_REGISTRO, V_ID_REDE_SOCIAL);
        END IF;

        -- ATRATIVOS TURISTICOS
        IF P_ID_ENTIDADE = 4 THEN
            INSERT INTO ATRATIVOS_TURISTICOS_REDES_SOCIAIS (ID_ATRATIVO, ID_REDE_SOCIAL)
            VALUES (P_ID_REGISTRO, V_ID_REDE_SOCIAL);
        END IF;

        -- SERVICOS AGRICULTURA
        IF P_ID_ENTIDADE = 5 THEN
            INSERT INTO SERVICOS_AGRICULTURA_REDES_SOCIAIS (ID_SERVICO, ID_REDE_SOCIAL)
            VALUES (P_ID_REGISTRO, V_ID_REDE_SOCIAL);
        END IF;

        -- INICIATIVAS PUBLICAS
        IF P_ID_ENTIDADE = 6 THEN
            INSERT INTO INICIATIVAS_PUBLICAS_REDES_SOCIAIS (ID_INICIATIVA, ID_REDE_SOCIAL)
            VALUES (P_ID_REGISTRO, V_ID_REDE_SOCIAL);
        END IF;

    END LOOP;
END PD_ENTIDADE_REDES_SOCIAIS_INSERT;



/* PROCEDURE PD_ENTIDADE_SUBCATEGORIAS_INSERT
-> FAZ O INSERT DA TABELA DE SUBCATEGORIAS DE UMA ENTIDADE
-> RECEBE COMO PARAMETRO O ARRAY "SUBCATEGORIAS" CADASTRADAS NO FRONT
-> RECEBE TAMBÉM O ID_ENTIDADE PARA IDENTIFICAR A ENTIDADE E O ID_REGISTRO PARA QUAL REGISTRO O INSERT DEVE OCORRER
-> "subcategorias": [
        {
            "id_subcategoria": 3
        },
        {
            "id_subcategoria": 6
        }
    ]
*/

CREATE OR REPLACE PROCEDURE PD_ENTIDADE_SUBCATEGORIAS_INSERT
(P_ENTIDADE_SUBCATEGORIAS IN JSON_ARRAY_T, P_ID_ENTIDADE IN NUMBER, P_ID_REGISTRO IN NUMBER)
AS
    V_ID_SUBCATEGORIA AGRICULTURA_URBANA_BAURU.SUBCATEGORIAS.ID_SUBCATEGORIA%TYPE;
    V_SUBCATEGORIAS   JSON_OBJECT_T;
BEGIN
    -- PERCORRE AS SUBCATEGORIAS INFORMADAS NO ARRAY
    FOR I IN 0 .. P_ENTIDADE_SUBCATEGORIAS.GET_SIZE() - 1 LOOP
        V_SUBCATEGORIAS := TREAT(P_ENTIDADE_SUBCATEGORIAS.GET(I) AS JSON_OBJECT_T);
        V_ID_SUBCATEGORIA := V_SUBCATEGORIAS.GET_NUMBER('id_subcategoria');

        -- DE ACORDO COM P_ID_ENTIDADE, A TABELA PARA ENTIDADE É ESCOLHIDA
        
        -- AGRICULTORES
        IF P_ID_ENTIDADE = 1 THEN
            INSERT INTO AGRICULTORES_SUBCATEGORIAS (ID_AGRICULTOR, ID_SUBCATEGORIA)
            VALUES (P_ID_REGISTRO, V_ID_SUBCATEGORIA);
        END IF;

        -- HORTAS URBANAS
        IF P_ID_ENTIDADE = 2 THEN
            INSERT INTO HORTAS_URBANAS_SUBCATEGORIAS (ID_HORTA, ID_SUBCATEGORIA)
            VALUES (P_ID_REGISTRO, V_ID_SUBCATEGORIA);
        END IF;

        -- FEIRAS MUNICIPAIS
        IF P_ID_ENTIDADE = 3 THEN
            INSERT INTO FEIRAS_MUNICIPAIS_SUBCATEGORIAS (ID_FEIRA, ID_SUBCATEGORIA)
            VALUES (P_ID_REGISTRO, V_ID_SUBCATEGORIA);
        END IF;

        -- ATRATIVOS TURISTICOS
        IF P_ID_ENTIDADE = 4 THEN
            INSERT INTO ATRATIVOS_TURISTICOS_SUBCATEGORIAS (ID_ATRATIVO, ID_SUBCATEGORIA)
            VALUES (P_ID_REGISTRO, V_ID_SUBCATEGORIA);
        END IF;

        -- SERVICOS AGRICULTURA
        IF P_ID_ENTIDADE = 5 THEN
            INSERT INTO SERVICOS_AGRICULTURA_SUBCATEGORIAS (ID_SERVICO, ID_SUBCATEGORIA)
            VALUES (P_ID_REGISTRO, V_ID_SUBCATEGORIA);
        END IF;

        -- INICIATIVAS PUBLICAS
        IF P_ID_ENTIDADE = 6 THEN
            INSERT INTO INICIATIVAS_PUBLICAS_SUBCATEGORIAS (ID_INICIATIVA, ID_SUBCATEGORIA)
            VALUES (P_ID_REGISTRO, V_ID_SUBCATEGORIA);
        END IF;

    END LOOP;
END PD_ENTIDADE_SUBCATEGORIAS_INSERT;