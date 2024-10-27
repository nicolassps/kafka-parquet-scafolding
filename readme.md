# Stack Kafka Streams + Connect + Parquet + DuckDB

## Descrição

Este projeto tem como objetivo criar um ambiente de desenvolvimento para trabalhar com o Kafka utilizando Docker. O ambiente é composto por um cluster Kafka, um servidor KSQL, um Schema Registry, um Kafka Connect e um Kafka UI. Além disso, o projeto inclui um serviço de geração de dados para popular o Kafka e um serviço de DuckDB para consultar os dados gerados em parquet.

Se trata de um scafolding para quem quer iniciar com a stack, há varias configurações de segurança adicional que podem ser feitas, como por exemplo, a utilização de SSL para comunicação entre os serviços.

## Como Usar

1. **Iniciar os serviços:**
   Execute o seguinte comando para construir e iniciar os containers em segundo plano:

```bash
   docker-compose up --build -d
```

2. **Gerar dados**: Após os serviços estarem em execução e os dados terem sido gerados, execute o seguinte comando para instalar as dependências e iniciar o DuckDB:
Para Windows:

```bash
.\duckdb\start.bat
```

Para Linux ou Mac:
```bash
./duckdb/start.sh
```

## Serviços

O projeto utiliza o seguinte docker-compose para configurar os serviços:

- Kafka: Um sistema de mensagens que permite a troca de mensagens entre produtores e consumidores de forma distribuída.
Zookeeper: Um serviço de coordenação para gerenciar a configuração e o estado do Kafka.
- KSQL Server: Um servidor para executar consultas SQL em streams de dados do Kafka.
Schema Registry: Um serviço que armazena os schemas de dados utilizados pelo Kafka.
- Kafka Connect: Uma ferramenta para integrar o Kafka com outras fontes e destinos de dados, permitindo a criação de conectores para diferentes sistemas.
- Kafka UI: Uma interface gráfica para visualizar e interagir com o cluster Kafka.
Init Kafka: Um serviço auxiliar que configura os tópicos necessários no Kafka na inicialização.
- Producer: Um serviço que envia dados para o Kafka.
- Scripts: setup-connectors.sh Script que configura schemas e conectores no Kafka