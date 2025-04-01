CREATE DATABASE IF NOT EXISTS db_sushi;
USE db_sushi;

CREATE TABLE Clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(15),
    data_cadastro DATE NOT NULL,
    pontos_fidelidade INT DEFAULT 0,
    ultima_visita DATE
);

CREATE TABLE Funcionarios (
    funcionario_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    sobrenome VARCHAR(50) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    data_contratacao DATE NOT NULL,
    salario DECIMAL(10, 2) NOT NULL,
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE CategoriasCardapio (
    categoria_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_categoria VARCHAR(50) NOT NULL,
    descricao TEXT
);

CREATE TABLE ItensCardapio (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id INT,
    nome_item VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(6, 2) NOT NULL,
    vegetariano BOOLEAN DEFAULT FALSE,
    picante BOOLEAN DEFAULT FALSE,
    sem_gluten BOOLEAN DEFAULT FALSE,
    calorias INT,
    url_imagem VARCHAR(255),
    FOREIGN KEY (categoria_id) REFERENCES CategoriasCardapio(categoria_id)
);

CREATE TABLE Ingredientes (
    ingrediente_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_ingrediente VARCHAR(100) NOT NULL,
    quantidade_estoque DECIMAL(10, 2) NOT NULL,
    unidade VARCHAR(20) NOT NULL,
    custo_por_unidade DECIMAL(6, 2) NOT NULL,
    fornecedor_id INT,
    data_ultimo_pedido DATE,
    data_validade DATE
);

CREATE TABLE ComponentesReceita (
    receita_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    ingrediente_id INT NOT NULL,
    quantidade DECIMAL(8, 3) NOT NULL,
    FOREIGN KEY (item_id) REFERENCES ItensCardapio(item_id),
    FOREIGN KEY (ingrediente_id) REFERENCES Ingredientes(ingrediente_id)
);

CREATE TABLE Fornecedores (
    fornecedor_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_fornecedor VARCHAR(100) NOT NULL,
    contato VARCHAR(100),
    telefone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    endereco TEXT,
    condicoes_pagamento VARCHAR(100)
);

ALTER TABLE Ingredientes
ADD CONSTRAINT fk_fornecedor
FOREIGN KEY (fornecedor_id) REFERENCES Fornecedores(fornecedor_id);

CREATE TABLE Pedidos (
    pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    funcionario_id INT,
    data_pedido DATETIME NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    metodo_pagamento VARCHAR(50),
    tipo_pedido VARCHAR(20) NOT NULL,
    status_pedido VARCHAR(20) NOT NULL,
    instrucoes_especiais TEXT,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionarios(funcionario_id)
);

CREATE TABLE ItensPedido (
    item_pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT NOT NULL,
    item_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(6, 2) NOT NULL,
    total_item DECIMAL(8, 2) GENERATED ALWAYS AS (quantidade * preco_unitario) STORED,
    solicitacoes_especiais TEXT,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
    FOREIGN KEY (item_id) REFERENCES ItensCardapio(item_id)
);

CREATE TABLE Reservas (
    reserva_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    data_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    tamanho_grupo INT NOT NULL,
    numero_mesa INT,
    solicitacoes_especiais TEXT,
    status VARCHAR(20) NOT NULL,
    data_criacao DATETIME NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE Mesas (
    mesa_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_mesa INT NOT NULL UNIQUE,
    capacidade INT NOT NULL,
    localizacao VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Disponível'
);


CREATE TABLE Promocoes (
    promocao_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_promocao VARCHAR(100) NOT NULL,
    descricao TEXT,
    percentual_desconto DECIMAL(5, 2),
    valor_desconto DECIMAL(6, 2),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    valor_minimo_pedido DECIMAL(6, 2),
    ativa BOOLEAN DEFAULT TRUE
);


CREATE TABLE ItensPromocao (
    item_promocao_id INT PRIMARY KEY AUTO_INCREMENT,
    promocao_id INT NOT NULL,
    item_id INT NOT NULL,
    FOREIGN KEY (promocao_id) REFERENCES Promocoes(promocao_id),
    FOREIGN KEY (item_id) REFERENCES ItensCardapio(item_id)
);

CREATE TABLE Feedback (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    pedido_id INT,
    cliente_id INT,
    avaliacao INT NOT NULL CHECK (avaliacao BETWEEN 1 AND 5),
    comentarios TEXT,
    data_feedback DATETIME NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id),
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
);

CREATE TABLE TransacoesEstoque (
    transacao_id INT PRIMARY KEY AUTO_INCREMENT,
    ingrediente_id INT NOT NULL,
    tipo_transacao VARCHAR(20) NOT NULL,
    quantidade DECIMAL(10, 2) NOT NULL,
    data_transacao DATETIME NOT NULL,
    funcionario_id INT,
    observacoes TEXT,
    FOREIGN KEY (ingrediente_id) REFERENCES Ingredientes(ingrediente_id),
    FOREIGN KEY (funcionario_id) REFERENCES Funcionarios(funcionario_id)
);

INSERT INTO Clientes (nome, sobrenome, email, telefone, data_cadastro, pontos_fidelidade, ultima_visita)
VALUES 
('Dyonnatth', 'Machado', 'dyon@gmail.com', '(11) 98765-4321', '2023-01-15', 120, '2025-02-15'),
('Anderson', 'Machado', 'am@hotmail.com', '(11) 97654-3210', '2023-03-22', 85, '2025-02-20'),
('Pedro', 'Oliveira', 'pedro.oliveira@uol.com.br', '(11) 96543-2109', '2023-05-10', 200, '2025-02-26'),
('Gislaine', 'Pereira', 'perapereira@gmail.com', '(11) 95432-1098', '2023-07-05', 150, '2025-02-10');

INSERT INTO Funcionarios (nome, sobrenome, cargo, data_contratacao, salario, telefone, email)
VALUES 
('Guilherme', 'Faggion', 'Chef de Sushi', '2024-05-10', 2200.00, '(14) 99321-0987', 'gui.f@sushizao.com'),
('Yuri', 'Fatec', 'Chefe de Cozinha', '2022-02-15', 3500.00, '(14) 99210-9876', 'yuri.f@sushizao.com'),
('Renan', 'Brandi', 'Garçom', '2023-08-20', 2200.00, '(14) 99109-8765', 'renan.b@gmail.com'),
('Thiago', 'Lima', 'Gerente', '2022-01-05', 3800.00, '(14) 99098-7654', 'thiago.l@sushizao.com');


INSERT INTO Fornecedores (nome_fornecedor, contato, telefone, endereco, email, condicoes_pagamento)
VALUES 
('Pesqueiro', 'Marcos Peixe', '(14) 99774-6543', 'pedidos@pesqueiromarcao.com.br', 'Rua pesca, 123, Bocaina, SP', '10 dias'),
('Importadora Asiática', 'João Victor Esteves', '(11) 99876-5432', 'joao@diretodojapao.com', 'Av. Jap, 300, São Paulo, SP', '15 dias'),
('Vegetais', 'Abner Périco Vidal', '(14) 99765-4321', 'abner@agriclavidal.com.br', 'Avenida Rural, Barra Bonita, SP', '45 dias'),
('Fornecedor de arroz', 'testeteste', '(14) 99654-3210', 'Teste@arrozdeteste.com', 'Rua do Comércio, 101, Jaú, SP', '5 dias');

INSERT INTO CategoriasCardapio (nome_categoria, descricao)
VALUES 
('Nigiri', '5 unidades de nigiri'),
('Temaki', '1 unidade de temaki'),
('Sashimi', '10 unidades de sashimi'),
('Entradas', 'Pequenos pratos para iniciar sua refeição'),
('Bebidas', 'Bebidas refrescantes');


INSERT INTO ItensCardapio (categoria_id, nome_item, descricao, preco, vegetariano, picante, sem_gluten, calorias)
VALUES 
(1, 'Nigiri de Salmão', 'Salmão e arroz', 12.50, FALSE, FALSE, TRUE, 68),
(1, 'Nigiri de Atum', 'Atume arroz', 14.50, FALSE, FALSE, TRUE, 70),
(2, 'Temaki Califórnia', 'Temaki com kani, abacate e pepino', 25.95, FALSE, FALSE, FALSE, 255),
(2, 'Temaki de Atum Picante', 'Temaki com atum picante e pepino', 28.95, FALSE, TRUE, FALSE, 290),
(2, 'Temaki Vegano', 'Temaki com vegetais variados', 22.95, TRUE, FALSE, FALSE, 180),
(3, 'Sashimi de Salmão', 'fatias de salmão', 32.95, FALSE, FALSE, TRUE, 175),
(3, 'Sashimi Variado', 'Fatias variadas de sashimi', 64.95, FALSE, FALSE, TRUE, 320),
(4, 'Edamame', 'Feijão de soja cozido com sal marinho', 18.95, TRUE, FALSE, TRUE, 155),
(4, 'Missoshiru', 'Sopa tradicional japonesa com tofu e algas', 14.50, TRUE, FALSE, FALSE, 80),
(5, 'Chá Verde', 'Chá verde tradicional japonês', 8.50, TRUE, FALSE, TRUE, 0);

INSERT INTO Ingredientes (nome_ingrediente, quantidade_estoque, unidade, custo_por_unidade, fornecedor_id, data_ultimo_pedido, data_validade)
VALUES 
('Salmão', 25.5, 'kg', 95.50, 1, '2025-02-20', '2025-03-05'),
('Atum', 18.2, 'kg', 120.75, 1, '2025-02-18', '2025-03-02'),
('Arroz para Sushi', 50.0, 'kg', 22.25, 4, '2025-02-15', '2025-08-15'),
('Folhas de Alga Nori', 200, 'folha', 0.75, 2, '2025-02-10', '2025-07-10'),
('Abacate', 30, 'unidade', 5.75, 3, '2025-02-25', '2025-03-02'),
('Pepino', 15, 'kg', 8.50, 3, '2025-02-25', '2025-03-05'),
('Kani', 10, 'kg', 45.75, 1, '2025-02-18', '2025-03-10'),
('Wasabi em Pó', 2, 'kg', 180.00, 2, '2025-02-10', '2025-06-10'),
('Shoyu', 20, 'litro', 15.25, 2, '2025-02-10', '2025-08-10'),
('Folhas de Chá Verde', 5, 'kg', 120.50, 2, '2025-02-10', '2025-06-10');

INSERT INTO ComponentesReceita (item_id, ingrediente_id, quantidade)
VALUES 
(1, 1, 0.03),
(1, 3, 0.02),


(3, 3, 0.1),
(3, 4, 1),
(3, 5, 0.25),
(3, 6, 0.03),
(3, 7, 0.04),


(8, 3, 0.15);

INSERT INTO Mesas (numero_mesa, capacidade, localizacao, status)
VALUES 
(1, 2, 'Janela', 'Disponível'),
(2, 2, 'Janela', 'Disponível'),
(3, 4, 'Centro', 'Disponível'),
(4, 4, 'Centro', 'Disponível'),
(5, 6, 'Centro', 'Disponível'),
(6, 8, 'Janela', 'Disponível'),
(7, 2, 'Bar', 'Disponível'),
(8, 2, 'Bar', 'Disponível');


INSERT INTO Promocoes (nome_promocao, descricao, percentual_desconto, data_inicio, data_fim, valor_minimo_pedido, ativa)
VALUES 
('Happy Hour', 'Preços especiais em temakis e entradas selecionadas', 20.00, '2025-01-01', '2025-12-31', 0.00, TRUE),
('Desconto para Estudantes', 'Mostre sua carteira de estudante para ganhar desconto', 10.00, '2025-01-01', '2025-12-31', 50.00, TRUE),
('Especial Família', 'Desconto em combinados para família', 15.00, '2025-03-01', '2025-04-30', 150.00, TRUE);

INSERT INTO ItensPromocao (promocao_id, item_id)
VALUES 
(1, 3), 
(1, 4),  
(1, 8),  
(3, 7);  

INSERT INTO Pedidos (cliente_id, funcionario_id, data_pedido, valor_total, metodo_pagamento, tipo_pedido, status_pedido, instrucoes_especiais)
VALUES 
(1, 3, '2025-02-15 18:30:00', 95.85, 'Cartão de Crédito', 'Local', 'Concluído', 'Sem wasabi, por favor'),
(2, 3, '2025-02-20 19:15:00', 125.70, 'Dinheiro', 'Para Viagem', 'Concluído', NULL),
(3, 3, '2025-02-26 20:00:00', 188.25, 'Cartão de Crédito', 'Local', 'Concluído', 'Gengibre extra'),
(4, 3, '2025-02-10 17:45:00', 72.40, 'Cartão de Débito', 'Entrega', 'Concluído', 'Tocar a campainha');

INSERT INTO ItensPedido (pedido_id, item_id, quantidade, preco_unitario, solicitacoes_especiais)
VALUES 
(1, 1, 2, 12.50, NULL),      
(1, 3, 1, 25.95, NULL),      
(1, 8, 1, 18.95, NULL),      
(1, 9, 2, 14.50, 'Tofu extra'), 

(2, 4, 2, 28.95, 'Bem picante'), 
(2, 6, 1, 32.95, NULL),   
(2, 10, 3, 8.50, NULL),

(3, 7, 1, 64.95, NULL),   
(3, 3, 2, 25.95, NULL),   
(3, 4, 1, 28.95, NULL),  
(3, 8, 1, 18.95, NULL), 
(3, 9, 4, 14.50, NULL),   

(4, 5, 1, 22.95, 'Sem pepino'), 
(4, 8, 2, 18.95, NULL),
(4, 10, 1, 8.50, NULL);

INSERT INTO Reservas (cliente_id, data_reserva, hora_reserva, tamanho_grupo, numero_mesa, solicitacoes_especiais, status, data_criacao)
VALUES 
(1, '2025-03-05', '19:00:00', 2, 1, 'Comemoração de aniversário', 'Confirmada', '2025-02-25 10:30:00'),
(3, '2025-03-10', '18:30:00', 4, 3, 'Preferência por mesa na janela', 'Confirmada', '2025-02-28 14:15:00');

INSERT INTO Feedback (pedido_id, cliente_id, avaliacao, comentarios, data_feedback)
VALUES 
(1, 1, 5, 'Excelente comida e atendimento!', '2025-02-16 09:30:00'),
(2, 2, 4, 'A comida estava horrível.', '2025-02-21 13:45:00'),
(3, 3, 5, 'Melhor sushi da cidade', '2025-02-27 11:20:00');

INSERT INTO TransacoesEstoque (ingrediente_id, tipo_transacao, quantidade, data_transacao, funcionario_id, observacoes)
VALUES 
(1, 'Recebido', 10.0, '2025-02-20 08:30:00', 4, 'Entrega semanal regular'),
(1, 'Utilizado', -2.5, '2025-02-26 17:00:00', 2, 'Consumo diário'),
(3, 'Recebido', 25.0, '2025-02-15 09:15:00', 4, 'Entrega mensal de arroz'),
(3, 'Utilizado', -4.0, '2025-02-26 17:00:00', 2, 'Consumo diário'),
(5, 'Descartado', -2.0, '2025-02-27 20:30:00', 4, 'Abacates muito maduros');


CREATE VIEW CardapioComCategorias AS
SELECT m.item_id, m.nome_item, m.preco, c.nome_categoria,
       m.vegetariano, m.picante, m.sem_gluten, m.calorias
FROM ItensCardapio m
JOIN CategoriasCardapio c ON m.categoria_id = c.categoria_id;

CREATE VIEW StatusEstoque AS
SELECT i.ingrediente_id, i.nome_ingrediente, i.quantidade_estoque, i.unidade,
       i.data_ultimo_pedido, i.data_validade, s.nome_fornecedor, s.telefone AS telefone_fornecedor
FROM Ingredientes i
JOIN Fornecedores s ON i.fornecedor_id = s.fornecedor_id;

CREATE VIEW ResumoPedidos AS
SELECT o.pedido_id, o.data_pedido, o.valor_total, o.tipo_pedido, o.status_pedido,
       CONCAT(c.nome, ' ', c.sobrenome) AS nome_cliente,
       CONCAT(s.nome, ' ', s.sobrenome) AS nome_funcionario,
       COUNT(oi.item_pedido_id) AS total_itens
FROM Pedidos o
LEFT JOIN Clientes c ON o.cliente_id = c.cliente_id
LEFT JOIN Funcionarios s ON o.funcionario_id = s.funcionario_id
LEFT JOIN ItensPedido oi ON o.pedido_id = oi.pedido_id
GROUP BY o.pedido_id;

DELIMITER //
CREATE PROCEDURE AdicionarItemCardapio(
    IN p_categoria_id INT,
    IN p_nome_item VARCHAR(100),
    IN p_descricao TEXT,
    IN p_preco DECIMAL(6, 2),
    IN p_vegetariano BOOLEAN,
    IN p_picante BOOLEAN,
    IN p_sem_gluten BOOLEAN,
    IN p_calorias INT
)
BEGIN
    INSERT INTO ItensCardapio (
        categoria_id, nome_item, descricao, preco, 
        vegetariano, picante, sem_gluten, calorias
    )
    VALUES (
        p_categoria_id, p_nome_item, p_descricao, p_preco,
        p_vegetariano, p_picante, p_sem_gluten, p_calorias
    );
    
    SELECT LAST_INSERT_ID() AS novo_item_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE CriarPedido(
    IN p_cliente_id INT,
    IN p_funcionario_id INT,
    IN p_tipo_pedido VARCHAR(20),
    IN p_metodo_pagamento VARCHAR(50),
    IN p_instrucoes_especiais TEXT
)
BEGIN
    DECLARE novo_pedido_id INT;
    
    INSERT INTO Pedidos (
        cliente_id, funcionario_id, data_pedido, valor_total,
        metodo_pagamento, tipo_pedido, status_pedido, instrucoes_especiais
    )
    VALUES (
        p_cliente_id, p_funcionario_id, NOW(), 0.00,
        p_metodo_pagamento, p_tipo_pedido, 'Pendente', p_instrucoes_especiais
    );
    
    SET novo_pedido_id = LAST_INSERT_ID();
    
    SELECT novo_pedido_id AS pedido_id;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE AdicionarItemPedido(
    IN p_pedido_id INT,
    IN p_item_id INT,
    IN p_quantidade INT,
    IN p_solicitacoes_especiais TEXT
)
BEGIN
    DECLARE v_preco_unitario DECIMAL(6, 2);
    
    SELECT preco INTO v_preco_unitario 
    FROM ItensCardapio 
    WHERE item_id = p_item_id;
    
    INSERT INTO ItensPedido (
        pedido_id, item_id, quantidade, preco_unitario, solicitacoes_especiais
    )
    VALUES (
        p_pedido_id, p_item_id, p_quantidade, v_preco_unitario, p_solicitacoes_especiais
    );
    
    UPDATE Pedidos 
    SET valor_total = valor_total + (v_preco_unitario * p_quantidade)
    WHERE pedido_id = p_pedido_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE ObterEstoqueBaixo(IN percentual_limite DECIMAL(5,2))
BEGIN

    SELECT 
        i.ingrediente_id,
        i.nome_ingrediente,
        i.quantidade_estoque,
        i.unidade,
        s.nome_fornecedor,
        s.telefone AS telefone_fornecedor
    FROM 
        Ingredientes i
    JOIN 
        Fornecedores s ON i.fornecedor_id = s.fornecedor_id
    WHERE 
        i.quantidade_estoque < (SELECT AVG(quantidade_estoque) * percentual_limite/100 FROM Ingredientes)
    ORDER BY 
        i.quantidade_estoque ASC;
END //
DELIMITER ;
