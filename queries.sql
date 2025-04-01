-- Passo 1: Criar tabela para armazenar os dados das operadoras
CREATE TABLE operadoras (
    id SERIAL PRIMARY KEY,
    registro_ans VARCHAR(20) UNIQUE NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    modalidade VARCHAR(100),
    uf CHAR(2),
    data_registro DATE
);

-- Passo 2: Criar tabela para armazenar os demonstrativos contábeis
CREATE TABLE demonstrativos_contabeis (
    id SERIAL PRIMARY KEY,
    registro_ans VARCHAR(20) REFERENCES operadoras(registro_ans),
    ano INT NOT NULL,
    trimestre INT NOT NULL,
    categoria VARCHAR(255) NOT NULL,
    valor NUMERIC(18,2) NOT NULL
);

-- Passo 3: Importar os dados dos arquivos CSV para as tabelas

COPY operadoras(registro_ans, cnpj, razao_social, nome_fantasia, modalidade, uf, data_registro)
FROM '/relatorio_cadop.csv' 
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

-- Passo 4: Unificar os demonstrativos contábeis se houver vários CSVs

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2023/1T2023.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2023/2T2023.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2023/3T2023.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2023/4T2023.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2024/1T2024.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2024/2T2024.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2024/3T2024.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';

COPY demonstrativos_contabeis(registro_ans, ano, trimestre, categoria, valor)
FROM '/2024/4T2024.csv'
DELIMITER ',' CSV HEADER ENCODING 'UTF-8';


-- Passo 5: Query para as 10 operadoras com maiores despesas no último trimestre
SELECT o.nome_fantasia, SUM(d.valor) AS total_despesas
FROM demonstrativos_contabeis d
JOIN operadoras o ON d.registro_ans = o.registro_ans
WHERE d.ano = EXTRACT(YEAR FROM CURRENT_DATE)
  AND d.trimestre = CASE 
        WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 1 AND 3 THEN 1
        WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 4 AND 6 THEN 2
        WHEN EXTRACT(MONTH FROM CURRENT_DATE) BETWEEN 7 AND 9 THEN 3
        ELSE 4 END
  AND d.categoria = 'EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR'
GROUP BY o.nome_fantasia
ORDER BY total_despesas DESC
LIMIT 10;

-- Passo 6: Query para as 10 operadoras com maiores despesas no último ano
SELECT o.nome_fantasia, SUM(d.valor) AS total_despesas
FROM demonstrativos_contabeis d
JOIN operadoras o ON d.registro_ans = o.registro_ans
WHERE d.ano = EXTRACT(YEAR FROM CURRENT_DATE) - 1
  AND d.categoria = 'EVENTOS/ SINISTROS CONHECIDOS OU AVISADOS DE ASSISTÊNCIA A SAÚDE MEDICO HOSPITALAR'
GROUP BY o.nome_fantasia
ORDER BY total_despesas DESC
LIMIT 10;
