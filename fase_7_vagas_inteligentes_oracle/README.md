# Vagas Inteligentes — Oracle SQL e PL/SQL

Projeto acadêmico desenvolvido na Fase 7 do PBL de Ciência de Dados
da FIAP, no cenário fictício da Cidade Alfa.

## Objetivo

Processar eventos de sensores de estacionamento, identificar pares de
entrada e saída, calcular permanências e gerar cobranças conforme as
regras de gratuidade e isenção.

## Tecnologias

- Oracle Database
- SQL e PL/SQL
- VS Code com extensão Oracle SQL Developer
- Git e GitHub

## Funcionalidades

- Associação de entradas e saídas por sensor e vaga.
- Cálculo do tempo de permanência em minutos.
- Identificação de eventos repetidos e inconsistências de sequência.
- Validação de data, status e existência do sensor/vaga no cadastro.
- Registro dos eventos rejeitados em log.
- Cobrança de vagas comuns após o período gratuito.
- Isenção para vagas de idosos e PCD.
- Mascaramento das placas na tabela de permanências.
- Manutenção das entradas sem saída como pendentes.

Os parâmetros de gratuidade e tarifa são consultados conforme
a vigência no instante de entrada.

## Resultados da carga de referência

| Indicador | Resultado |
|---|---:|
| Eventos lidos | 21.195 |
| Eventos processados com sucesso | 20.688 |
| Eventos rejeitados | 300 |
| Entradas aguardando saída | 207 |
| Permanências geradas | 10.344 |
| Cobranças geradas | 9.117 |

Na validação final, foram encontrados:

- 0 durações inconsistentes.
- 0 placas fora do padrão de mascaramento.
- 0 cobranças inconsistentes.
- 0 cobranças faltantes.

Uma nova execução sobre a mesma carga concluída leu as 207 entradas
pendentes, sem gerar novas permanências, cobranças ou rejeições.

## Organização

- `sql/`: criação da base, rotinas, testes e validações.
- `evidencias/`: capturas das etapas de desenvolvimento e dos resultados.
- `historico/`: diagnóstico e correção pontual do arredondamento.

Os prints incluem resultados intermediários, anteriores à correção.
A evidência `32.png` apresenta as quatro verificações finais zeradas.

## Como executar

Use uma conexão Oracle em um esquema destinado ao projeto.
Execute os scripts em modo de execução de script, respeitando a ordem:

1. `sql/00_verificacao_ambiente.sql`
2. `sql/Cria_Vagas_Inteligentes_v1.sql`
3. `sql/01_validacao_carga_inicial.sql`
4. `sql/02_diagnostico_eventos.sql`
5. `sql/FUN_CALCULAR_TEMPO_PERMANENCIA.sql`
6. `sql/FUN_MASCARAR_PLACA.sql`
7. `sql/FUN_DEVE_COBRAR.sql`
8. `sql/PRC_REGISTRAR_ERRO.sql`
9. `sql/PRC_PROCESSAR_EVENTOS_SENSOR.sql`
10. `sql/03_teste_tempo_permanencia.sql`
11. `sql/04_teste_mascaramento_placa.sql`
12. `sql/05_teste_regra_cobranca.sql`
13. `sql/06_validacao_rotinas.sql`
14. `sql/07_execucao_processamento.sql`
15. `sql/08_validacao_processamento.sql`
16. `sql/09_validacao_regras_resultado.sql`
17. `sql/12_evidencias_entrega.sql`

Antes do processamento, confira se as cinco rotinas estão VALID
e se a consulta de erros de compilação não retorna registros.

A criação e carga inicial devem ser executadas somente em uma base nova.
O processamento grava dados e realiza COMMIT.

As verificações da seção 09 consideram os parâmetros da carga de
referência: 30 minutos gratuitos e R$ 0,20 por minuto excedente.

## Correção de arredondamento

Durante a validação, foram identificadas diferenças no arredondamento
de durações com meio minuto. O cálculo foi padronizado:

    ROUND(ROUND((p_dt_saida - p_dt_entrada) * 86400) / 60)

Na base já processada, foram corrigidas seis permanências e quatro
cobranças. A função publicada já incorpora a correção.

Os arquivos da pasta `historico/` não fazem parte da instalação normal.
O script `11_correcao_arredondamento.sql` contém uma correção específica
da base utilizada durante o desenvolvimento e não deve ser executado
em uma nova instalação.

## Escopo e limitações

- Projeto acadêmico com dados fictícios.
- O mascaramento é aplicado na tabela de permanências; a staging
  mantém os dados recebidos na carga.
- A evidência de RN04 demonstra rejeição por sensor/vaga não cadastrado.
  As constraints da staging impedem a inserção de datas nulas e status
  inválidos na estrutura fornecida.
- O teste de reexecução cobre a mesma carga após processamento concluído.
- Os logs utilizam transação autônoma e permanecem gravados mesmo
  se a transação principal sofrer rollback.

## Origem do material

O cenário, a estrutura inicial, a carga e as rotinas-base foram
fornecidos pela FIAP. O trabalho do grupo compreendeu a complementação
das regras, funções auxiliares, testes, validações e correção do cálculo
de permanência.

