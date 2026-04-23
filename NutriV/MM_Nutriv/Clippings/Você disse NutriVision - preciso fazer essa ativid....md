---
title: "Você disse NutriVision - preciso fazer essa ativid..."
source: "https://gemini.google.com/app/ea62fb908689b87e?hl=pt-BR"
author:
published:
created: 2026-04-23
description: "Gemini conversation with 4 messages"
tags:
  - "clippings"
---
**Instituição:** Universidade Cruzeiro do Sul **Disciplina:** Tópicos Avançados em Sistemas de Informação I **Tema:** Padrões de Arquitetura de Software - Camadas

---

## 1\. Definição do Padrão

A arquitetura em camadas (**Layered Architecture**) é um padrão que organiza o software em níveis horizontais, onde cada nível possui responsabilidades distintas. Esse modelo promove a separação de interesses, facilitando a manutenção e a realização de testes, sendo amplamente utilizado em sistemas monolíticos e aplicações empresariais.

## 2\. Estrutura do Projeto NutriVision

Com base no modelo de 4 camadas apresentado em aula, identificamos a seguinte disposição para o aplicativo:

### **A. Camada de Apresentação (Presentation Layer)**

- **Função:** Interface do usuário e manipulação de entrada/saída (browser ou mobile).
- **No NutriVision:** Telas desenvolvidas em Flutter, widgets de captura de imagem pela câmera e exibição dos resultados nutricionais.

### **B. Camada de Negócio (Business/Service Layer)**

- **Função:** Contém a lógica das regras de negócio e processamento de dados.
- **No NutriVision:** O motor de **Visão Computacional** que identifica o alimento e a lógica que calcula os macronutrientes com base na imagem processada.

### **C. Camada de Persistência (Persistence Layer)**

- **Função:** Gerencia o acesso aos dados e o mapeamento relacional (Repository/DAO).
- **No NutriVision:** Repositórios que organizam o fluxo de salvamento do histórico de refeições e logs de consumo do usuário.

### **D. Camada de Banco de Dados (Database Layer)**

- **Função:** Local físico onde os dados são armazenados.
- **No NutriVision:** Banco de dados (local ou em nuvem) contendo a tabela nutricional de referência e os dados cadastrais.

---

## 3\. Características Identificadas

- **Isolamento:** As camadas funcionam como abstrações independentes. Alterações na lógica de cálculo (camada de negócio) não afetam diretamente a interface, desde que a comunicação entre elas seja mantida.
- **Fluxo de Requisição:** O projeto segue um fluxo **"fechado"**, o que obriga a requisição a passar pela camada inferior adjacente, garantindo maior controle sobre as regras de negócio.

## 4\. Avaliação Técnica

- **Vantagens:** A implementação no NutriVision ganha simplicidade, alta coesão e uma clara separação de conceitos.
- **Desvantagens:** É necessário cuidado para evitar o **"efeito canudinho"**, onde uma requisição atravessa várias camadas apenas para repassar dados, sem executar lógica relevante.