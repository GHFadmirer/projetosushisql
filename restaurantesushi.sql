-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 01, 2025 at 09:16 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `restaurantesushi`
--
CREATE DATABASE IF NOT EXISTS `restaurantesushi` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `restaurantesushi`;

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AdicionarItemCardapio` (IN `p_categoria_id` INT, IN `p_nome_item` VARCHAR(100), IN `p_descricao` TEXT, IN `p_preco` DECIMAL(6,2), IN `p_vegetariano` BOOLEAN, IN `p_picante` BOOLEAN, IN `p_sem_gluten` BOOLEAN, IN `p_calorias` INT)   BEGIN
    INSERT INTO ItensCardapio (
        categoria_id, nome_item, descricao, preco, 
        vegetariano, picante, sem_gluten, calorias
    )
    VALUES (
        p_categoria_id, p_nome_item, p_descricao, p_preco,
        p_vegetariano, p_picante, p_sem_gluten, p_calorias
    );
    
    SELECT LAST_INSERT_ID() AS novo_item_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AdicionarItemPedido` (IN `p_pedido_id` INT, IN `p_item_id` INT, IN `p_quantidade` INT, IN `p_solicitacoes_especiais` TEXT)   BEGIN
    DECLARE v_preco_unit DECIMAL(6, 2);
    
    SELECT preco INTO v_preco_unit 
    FROM ItensCardapio 
    WHERE item_id = p_item_id;
    
    INSERT INTO ItensPedido (
        pedido_id, item_id, quantidade, preco_unit, solicitacoes_especiais
    )
    VALUES (
        p_pedido_id, p_item_id, p_quantidade, v_preco_unit, p_solicitacoes_especiais
    );
    
    UPDATE Pedidos 
    SET valor_total = valor_total + (v_preco_unit * p_quantidade)
    WHERE pedido_id = p_pedido_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CriarPedido` (IN `p_cliente_id` INT, IN `p_funcionario_id` INT, IN `p_tipo_pedido` VARCHAR(20), IN `p_metodo_pagamento` VARCHAR(50), IN `p_instrucoes_especiais` TEXT)   BEGIN
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
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterEstoqueBaixo` (IN `percentual_limite` DECIMAL(5,2))   BEGIN
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `cardapiocomcategorias`
-- (See below for the actual view)
--
CREATE TABLE `cardapiocomcategorias` (
`item_id` int(11)
,`nome_item` varchar(100)
,`preco` decimal(6,2)
,`nome_categoria` varchar(50)
,`vegetariano` tinyint(1)
,`picante` tinyint(1)
,`sem_gluten` tinyint(1)
,`calorias` int(11)
);

-- Por algum motivo o phpmyadmin modificou a forma que estava isso, era originalmente um boolean.


-- --------------------------------------------------------

--
-- Table structure for table `categoriascardapio`
--

CREATE TABLE `categoriascardapio` (
  `categoria_id` int(11) NOT NULL,
  `nome_categoria` varchar(50) NOT NULL,
  `descricao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categoriascardapio`
--

INSERT INTO `categoriascardapio` (`categoria_id`, `nome_categoria`, `descricao`) VALUES
(1, 'Nigiri', 'Sushi tradicional consistindo em uma fatia de peixe cru sobre arroz temperado'),
(2, 'Temaki', 'Cone de alga recheado com arroz e diversos ingredientes'),
(3, 'Sashimi', 'Fatias finas de peixe cru servido sem arroz'),
(4, 'Entradas', 'Pequenos pratos para iniciar sua refeição'),
(5, 'Bebidas', 'Bebidas refrescantes para complementar sua experiência de sushi');

-- --------------------------------------------------------

--
-- Table structure for table `clientes`
--

CREATE TABLE `clientes` (
  `cliente_id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `sobrenome` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefone` varchar(15) DEFAULT NULL,
  `data_cadastro` date NOT NULL,
  `pontos_fidelidade` int(11) DEFAULT 0,
  `ultima_visita` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clientes`
--

INSERT INTO `clientes` (`cliente_id`, `nome`, `sobrenome`, `email`, `telefone`, `data_cadastro`, `pontos_fidelidade`, `ultima_visita`) VALUES
(1, 'Dyonnatth', 'Machado', 'dyon@gmail.com', '(11) 98765-4321', '2023-01-15', 120, '2025-02-15'),
(2, 'Anderson', 'Machado', 'am@hotmail.com', '(11) 97654-3210', '2023-03-22', 85, '2025-02-20'),
(3, 'Pedro', 'Oliveira', 'pedro.oliveira@uol.com.br', '(11) 96543-2109', '2023-05-10', 200, '2025-02-26'),
(4, 'Gislaine', 'Pereira', 'perapereira@gmail.com', '(11) 95432-1098', '2023-07-05', 150, '2025-02-10');

-- --------------------------------------------------------

--
-- Table structure for table `componentesreceita`
--

CREATE TABLE `componentesreceita` (
  `receita_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `ingrediente_id` int(11) NOT NULL,
  `quantidade` decimal(8,3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `componentesreceita`
--

INSERT INTO `componentesreceita` (`receita_id`, `item_id`, `ingrediente_id`, `quantidade`) VALUES
(1, 1, 1, 0.030),
(2, 1, 3, 0.020),
(3, 3, 3, 0.100),
(4, 3, 4, 1.000),
(5, 3, 5, 0.250),
(6, 3, 6, 0.030),
(7, 3, 7, 0.040),
(8, 8, 3, 0.150);

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `feedback_id` int(11) NOT NULL,
  `pedido_id` int(11) DEFAULT NULL,
  `cliente_id` int(11) DEFAULT NULL,
  `avaliacao` int(11) NOT NULL CHECK (`avaliacao` between 1 and 5),
  `comentarios` text DEFAULT NULL,
  `data_feedback` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `feedback`
--

INSERT INTO `feedback` (`feedback_id`, `pedido_id`, `cliente_id`, `avaliacao`, `comentarios`, `data_feedback`) VALUES
(1, 1, 1, 5, 'Excelente comida e atendimento!', '2025-02-16 21:30:00'),
(2, 2, 2, 4, 'Horrivel, espero que sejam presos.', '2025-02-21 13:45:00'),
(3, 3, 3, 5, 'Melhor sushi da região!', '2025-02-27 20:20:00');

-- --------------------------------------------------------

--
-- Table structure for table `fornecedores`
--

CREATE TABLE `fornecedores` (
  `fornecedor_id` int(11) NOT NULL,
  `nome_fornecedor` varchar(100) NOT NULL,
  `contato` varchar(100) DEFAULT NULL,
  `telefone` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `endereco` text DEFAULT NULL,
  `condicoes_pagamento` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fornecedores`
--

INSERT INTO `fornecedores` (`fornecedor_id`, `nome_fornecedor`, `contato`, `telefone`, `email`, `endereco`, `condicoes_pagamento`) VALUES
(1, 'Pesqueiro', 'Marcos Peixe', '(14) 99774-6543', 'pedidos@pesqueiromarcao.com.br', 'Rua pesca, 123, Bocaina, SP', '10 dias'),
(2, 'Importadora Asiática', 'João Victor Esteves', '(11) 99876-5432', 'joao@diretodojapao.com', 'Av. Jap, 300, São Paulo, SP', '15 dias'),
(3, 'Vegetais', 'Abner Périco Vidal', '(14) 99765-4321', 'abner@agriclavidal.com.br', 'Avenida Rural, Barra Bonita, SP', '45 dias'),
(4, 'Fornecedor de arroz', 'testeteste', '(14) 99654-3210', 'Teste@arrozdeteste.com', 'Rua do Comércio, 101, Jaú, SP', '5 dias');

-- --------------------------------------------------------

--
-- Table structure for table `funcionarios`
--

CREATE TABLE `funcionarios` (
  `funcionario_id` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `sobrenome` varchar(50) NOT NULL,
  `cargo` varchar(50) NOT NULL,
  `data_contratacao` date NOT NULL,
  `salario` decimal(10,2) NOT NULL,
  `telefone` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `funcionarios`
--

INSERT INTO `funcionarios` (`funcionario_id`, `nome`, `sobrenome`, `cargo`, `data_contratacao`, `salario`, `telefone`, `email`) VALUES
(1, 'Guilherme', 'Faggion', 'Chef de Sushi', '2024-05-10', 2200.00, '(14) 99321-0987', 'gui.f@sushizao.com'),
(2, 'Yuri', 'Fatec', 'Chefe de Cozinha', '2022-02-15', 3500.00, '(14) 99210-9876', 'yuri.f@sushizao.com'),
(3, 'Renan', 'Brandi', 'Garçom', '2023-08-20', 2200.00, '(14) 99109-8765', 'renan.b@gmail.com'),
(4, 'Thiago', 'Lima', 'Gerente', '2022-01-05', 3800.00, '(14) 99098-7654', 'thiago.l@sushizao.com');

-- --------------------------------------------------------

--
-- Table structure for table `ingredientes`
--

CREATE TABLE `ingredientes` (
  `ingrediente_id` int(11) NOT NULL,
  `nome_ingrediente` varchar(100) NOT NULL,
  `quantidade_estoque` decimal(10,2) NOT NULL,
  `unidade` varchar(20) NOT NULL,
  `custo_por_unidade` decimal(6,2) NOT NULL,
  `fornecedor_id` int(11) DEFAULT NULL,
  `data_ultimo_pedido` date DEFAULT NULL,
  `data_validade` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ingredientes`
--

INSERT INTO `ingredientes` (`nome_ingrediente`, `quantidade_estoque`, `unidade`, `custo_por_unidade`, `fornecedor_id`, `data_ultimo_pedido`, `data_validade`) VALUES
('Salmão', 25.50, 'kg', 95.50, 1, '2025-02-20', '2025-03-05'),
('Atum', 18.20, 'kg', 120.75, 1, '2025-02-18', '2025-03-02'),
('Arroz', 50.00, 'kg', 22.25, 4, '2025-02-15', '2025-08-15'),
('Alga Nori', 200.00, 'folha', 0.75, 2, '2025-02-10', '2025-07-10'),
('Abacate', 30.00, 'unidade', 5.75, 3, '2025-02-25', '2025-03-02'),
('Pepino', 15.00, 'kg', 8.50, 3, '2025-02-25', '2025-03-05'),
('Kani', 10.00, 'kg', 45.75, 1, '2025-02-18', '2025-03-10'),
('Wasabi em Pó', 2.00, 'kg', 180.00, 2, '2025-02-10', '2025-06-10'),
('Shoyu', 20.00, 'litro', 15.25, 2, '2025-02-10', '2025-08-10'),

-- --------------------------------------------------------

--
-- Table structure for table `itenscardapio`
--

CREATE TABLE `itenscardapio` (
  `item_id` int(11) NOT NULL,
  `categoria_id` int(11) DEFAULT NULL,
  `nome_item` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` decimal(6,2) NOT NULL,
  `vegetariano` tinyint(1) DEFAULT 0,
  `picante` tinyint(1) DEFAULT 0,
  `sem_gluten` tinyint(1) DEFAULT 0,
  `calorias` int(11) DEFAULT NULL,
  `url_imagem` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `itenscardapio`
--

INSERT INTO `itenscardapio` (`categoria_id`, `nome_item`, `descricao`, `preco`, `vegetariano`, `picante`, `sem_gluten`, `calorias`, `url_imagem`) VALUES
(1, 'Nigiri de Salmão', 'Salmão e arroz', 12.50, 0, 0, 1, 68, NULL),
(1, 'Nigiri de Atum', 'Atume arroz', 14.50, 0, 0, 1, 70, NULL),
(2, 'Temaki Califórnia', 'Temaki com kani, abacate e pepino', 25.95, 0, 0, 0, 255, NULL),
(2, 'Temaki de Atum Picante', 'Temaki com atum picante e pepino', 28.95, 0, 1, 0, 290, NULL),
(2, 'Temaki Vegano', 'Temaki de vegetais variados', 22.95, 1, 0, 0, 180, NULL),
(3, 'Sashimi de Salmão', 'Fatias de salmão', 32.95, 0, 0, 1, 175, NULL),
(3, 'Sashimi Variado', 'Fatias de sashimi', 64.95, 0, 0, 1, 320, NULL),
(4, 'Missoshiru', 'Sopa tradicional japonesa com tofu e algas', 14.50, 1, 0, 0, 80, NULL),
(5, 'Chá Verde', 'Chá verde tradicional japonês', 8.50, 1, 0, 1, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `itenspedido`
--

CREATE TABLE `itenspedido` (
  `item_pedido_id` int(11) NOT NULL,
  `pedido_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantidade` int(11) NOT NULL,
  `preco_unit` decimal(6,2) NOT NULL,
  `total_item` decimal(8,2) GENERATED ALWAYS AS (`quantidade` * `preco_unit`) STORED,
  `solicitacoes_especiais` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `itenspedido`
--

INSERT INTO `itenspedido` (`pedido_id`, `item_id`, `quantidade`, `preco_unit`, `solicitacoes_especiais`) VALUES
(1, 1, 2, 12.50, NULL),
(1, 3, 1, 25.95, NULL),
(1, 8, 1, 18.95, NULL),
(1, 9, 2, 14.50, 'mais tofu'),
(2, 4, 2, 28.95, 'extra picante'),
(2, 6, 1, 32.95, NULL),
(2, 9, 3, 8.50, NULL),
(3, 7, 1, 64.95, NULL),
(3, 3, 2, 25.95, NULL),
(3, 4, 1, 28.95, NULL),
(3, 8, 1, 18.95, NULL),
(3, 9, 4, 14.50, NULL),
(4, 5, 1, 22.95, 'Sem pepino'),
(4, 8, 2, 18.95, NULL),
(4, 9, 1, 8.50, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `itenspromocao`
--

CREATE TABLE `itenspromocao` (
  `item_promocao_id` int(11) NOT NULL,
  `promocao_id` int(11) NOT NULL,
  `item_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `itenspromocao`
--

--por algum motivo nao esta funcionando sem coloca o item_promocao_id manualmente
INSERT INTO `itenspromocao` (`item_promocao_id`, `promocao_id`, `item_id`) VALUES
(1, 1, 3),
(2, 1, 4),
(3, 1, 8),
(4, 3, 7);

-- --------------------------------------------------------

--
-- Table structure for table `mesas`
--

CREATE TABLE `mesas` (
  `mesa_id` int(11) NOT NULL,
  `numero_mesa` int(11) NOT NULL,
  `capacidade` int(11) NOT NULL,
  `localizacao` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Disponível'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `mesas`
--

INSERT INTO `mesas` (`mesa_id`, `numero_mesa`, `capacidade`, `localizacao`, `status`) VALUES
(1, 1, 2, 'Janela', 'Disponível'),
(2, 2, 2, 'Janela', 'Disponível'),
(3, 3, 4, 'Centro', 'Disponível'),
(4, 4, 4, 'Centro', 'Disponível'),
(5, 5, 6, 'Centro', 'Disponível'),
(6, 6, 8, 'Janela', 'Disponível'),
(7, 7, 2, 'Bar', 'Disponível'),
(8, 8, 2, 'Bar', 'Disponível');

-- --------------------------------------------------------

--
-- Table structure for table `pedidos`
--

CREATE TABLE `pedidos` (
  `pedido_id` int(11) NOT NULL,
  `cliente_id` int(11) DEFAULT NULL,
  `funcionario_id` int(11) DEFAULT NULL,
  `data_pedido` datetime NOT NULL,
  `valor_total` decimal(10,2) NOT NULL,
  `metodo_pagamento` varchar(50) DEFAULT NULL,
  `tipo_pedido` varchar(20) NOT NULL,
  `status_pedido` varchar(20) NOT NULL,
  `instrucoes_especiais` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pedidos`
--

INSERT INTO `pedidos` (`pedido_id`, `cliente_id`, `funcionario_id`, `data_pedido`, `valor_total`, `metodo_pagamento`, `tipo_pedido`, `status_pedido`, `instrucoes_especiais`) VALUES
(1, 1, 3, '2025-02-15 18:30:00', 95.85, 'Cartão de Crédito', 'Local', 'Concluído', 'Sem wasabi, por favor'),
(2, 2, 3, '2025-02-20 19:15:00', 125.70, 'Dinheiro', 'Para Viagem', 'Concluído', NULL),
(3, 3, 3, '2025-02-26 20:00:00', 188.25, 'Cartão de Crédito', 'Local', 'Concluído', 'Gengibre extra'),
(4, 4, 3, '2025-02-10 17:45:00', 72.40, 'Cartão de Débito', 'Entrega', 'Concluído', 'Tocar a campainha');

-- --------------------------------------------------------

--
-- Table structure for table `promocoes`
--

CREATE TABLE `promocoes` (
  `promocao_id` int(11) NOT NULL,
  `nome_promocao` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `percentual_desconto` decimal(5,2) DEFAULT NULL,
  `valor_desconto` decimal(6,2) DEFAULT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date NOT NULL,
  `valor_minimo_pedido` decimal(6,2) DEFAULT NULL,
  `ativa` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promocoes`
--

INSERT INTO `promocoes` (`promocao_id`, `nome_promocao`, `descricao`, `percentual_desconto`, `valor_desconto`, `data_inicio`, `data_fim`, `valor_minimo_pedido`, `ativa`) VALUES
(1, 'Happy Hour', 'Preços especiais em temakis e entradas selecionadas', 20.00, NULL, '2025-01-01', '2025-12-31', 0.00, 1),
(2, 'Desconto para Estudantes', 'Mostre sua carteira de estudante para ganhar desconto', 10.00, NULL, '2025-01-01', '2025-12-31', 50.00, 1),
(3, 'Especial Família', 'Desconto em combinados para família', 15.00, NULL, '2025-03-01', '2025-04-30', 150.00, 1);

-- --------------------------------------------------------

--
-- Table structure for table `reservas`
--

CREATE TABLE `reservas` (
  `reserva_id` int(11) NOT NULL,
  `cliente_id` int(11) DEFAULT NULL,
  `data_reserva` date NOT NULL,
  `hora_reserva` time NOT NULL,
  `tamanho_grupo` int(11) NOT NULL,
  `numero_mesa` int(11) DEFAULT NULL,
  `solicitacoes_especiais` text DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `data_criacao` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `reservas`
--

INSERT INTO `reservas` (`reserva_id`, `cliente_id`, `data_reserva`, `hora_reserva`, `tamanho_grupo`, `numero_mesa`, `solicitacoes_especiais`, `status`, `data_criacao`) VALUES
(1, 1, '2025-03-05', '19:00:00', 2, 1, 'Comemoração de aniversário', 'Confirmada', '2025-02-25 10:30:00'),
(2, 3, '2025-03-10', '18:30:00', 4, 3, 'Preferência por mesa na janela', 'Confirmada', '2025-02-28 14:15:00');

-- --------------------------------------------------------

--
-- Stand-in structure for view `resumopedidos`
-- (See below for the actual view)
--
CREATE TABLE `resumopedidos` (
`pedido_id` int(11)
,`data_pedido` datetime
,`valor_total` decimal(10,2)
,`tipo_pedido` varchar(20)
,`status_pedido` varchar(20)
,`nome_cliente` varchar(101)
,`nome_funcionario` varchar(101)
,`total_itens` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `statusestoque`
-- (See below for the actual view)
--
CREATE TABLE `statusestoque` (
`ingrediente_id` int(11)
,`nome_ingrediente` varchar(100)
,`quantidade_estoque` decimal(10,2)
,`unidade` varchar(20)
,`data_ultimo_pedido` date
,`data_validade` date
,`nome_fornecedor` varchar(100)
,`telefone_fornecedor` varchar(15)
);

-- --------------------------------------------------------

--
-- Table structure for table `transacoesestoque`
--

CREATE TABLE `transacoesestoque` (
  `transacao_id` int(11) NOT NULL,
  `ingrediente_id` int(11) NOT NULL,
  `tipo_transacao` varchar(20) NOT NULL,
  `quantidade` decimal(10,2) NOT NULL,
  `data_transacao` datetime NOT NULL,
  `funcionario_id` int(11) DEFAULT NULL,
  `observacoes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transacoesestoque`
--

INSERT INTO `transacoesestoque` (`transacao_id`, `ingrediente_id`, `tipo_transacao`, `quantidade`, `data_transacao`, `funcionario_id`, `observacoes`) VALUES
(1, 1, 'Recebido', 10.00, '2025-02-20 08:30:00', 4, 'Entrega semanal regular'),
(2, 1, 'Utilizado', -2.50, '2025-02-26 17:00:00', 2, 'Consumo diário'),
(3, 3, 'Recebido', 25.00, '2025-02-15 09:15:00', 4, 'Entrega mensal de arroz'),
(4, 3, 'Utilizado', -4.00, '2025-02-26 17:00:00', 2, 'Consumo diário'),
(5, 5, 'Descartado', -2.00, '2025-02-27 20:30:00', 4, 'Abacates muito maduros');

-- --------------------------------------------------------

--
-- Structure for view `cardapiocomcategorias`
--
DROP TABLE IF EXISTS `cardapiocomcategorias`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cardapiocomcategorias`  AS SELECT `m`.`item_id` AS `item_id`, `m`.`nome_item` AS `nome_item`, `m`.`preco` AS `preco`, `c`.`nome_categoria` AS `nome_categoria`, `m`.`vegetariano` AS `vegetariano`, `m`.`picante` AS `picante`, `m`.`sem_gluten` AS `sem_gluten`, `m`.`calorias` AS `calorias` FROM (`itenscardapio` `m` join `categoriascardapio` `c` on(`m`.`categoria_id` = `c`.`categoria_id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `resumopedidos`
--
DROP TABLE IF EXISTS `resumopedidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `resumopedidos`  AS SELECT `o`.`pedido_id` AS `pedido_id`, `o`.`data_pedido` AS `data_pedido`, `o`.`valor_total` AS `valor_total`, `o`.`tipo_pedido` AS `tipo_pedido`, `o`.`status_pedido` AS `status_pedido`, concat(`c`.`nome`,' ',`c`.`sobrenome`) AS `nome_cliente`, concat(`s`.`nome`,' ',`s`.`sobrenome`) AS `nome_funcionario`, count(`oi`.`item_pedido_id`) AS `total_itens` FROM (((`pedidos` `o` left join `clientes` `c` on(`o`.`cliente_id` = `c`.`cliente_id`)) left join `funcionarios` `s` on(`o`.`funcionario_id` = `s`.`funcionario_id`)) left join `itenspedido` `oi` on(`o`.`pedido_id` = `oi`.`pedido_id`)) GROUP BY `o`.`pedido_id` ;

-- --------------------------------------------------------

--
-- Structure for view `statusestoque`
--
DROP TABLE IF EXISTS `statusestoque`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `statusestoque`  AS SELECT `i`.`ingrediente_id` AS `ingrediente_id`, `i`.`nome_ingrediente` AS `nome_ingrediente`, `i`.`quantidade_estoque` AS `quantidade_estoque`, `i`.`unidade` AS `unidade`, `i`.`data_ultimo_pedido` AS `data_ultimo_pedido`, `i`.`data_validade` AS `data_validade`, `s`.`nome_fornecedor` AS `nome_fornecedor`, `s`.`telefone` AS `telefone_fornecedor` FROM (`ingredientes` `i` join `fornecedores` `s` on(`i`.`fornecedor_id` = `s`.`fornecedor_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categoriascardapio`
--
ALTER TABLE `categoriascardapio`
  ADD PRIMARY KEY (`categoria_id`);

--
-- Indexes for table `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`cliente_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `componentesreceita`
--
ALTER TABLE `componentesreceita`
  ADD PRIMARY KEY (`receita_id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `ingrediente_id` (`ingrediente_id`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`feedback_id`),
  ADD KEY `pedido_id` (`pedido_id`),
  ADD KEY `cliente_id` (`cliente_id`);

--
-- Indexes for table `fornecedores`
--
ALTER TABLE `fornecedores`
  ADD PRIMARY KEY (`fornecedor_id`);

--
-- Indexes for table `funcionarios`
--
ALTER TABLE `funcionarios`
  ADD PRIMARY KEY (`funcionario_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `ingredientes`
--
ALTER TABLE `ingredientes`
  ADD PRIMARY KEY (`ingrediente_id`),
  ADD KEY `fk_fornecedor` (`fornecedor_id`);

--
-- Indexes for table `itenscardapio`
--
ALTER TABLE `itenscardapio`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `categoria_id` (`categoria_id`);

--
-- Indexes for table `itenspedido`
--
ALTER TABLE `itenspedido`
  ADD PRIMARY KEY (`item_pedido_id`),
  ADD KEY `pedido_id` (`pedido_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `itenspromocao`
--
ALTER TABLE `itenspromocao`
  ADD PRIMARY KEY (`item_promocao_id`),
  ADD KEY `promocao_id` (`promocao_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `mesas`
--
ALTER TABLE `mesas`
  ADD PRIMARY KEY (`mesa_id`),
  ADD UNIQUE KEY `numero_mesa` (`numero_mesa`);

--
-- Indexes for table `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`pedido_id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `funcionario_id` (`funcionario_id`);

--
-- Indexes for table `promocoes`
--
ALTER TABLE `promocoes`
  ADD PRIMARY KEY (`promocao_id`);

--
-- Indexes for table `reservas`
--
ALTER TABLE `reservas`
  ADD PRIMARY KEY (`reserva_id`),
  ADD KEY `cliente_id` (`cliente_id`);

--
-- Indexes for table `transacoesestoque`
--
ALTER TABLE `transacoesestoque`
  ADD PRIMARY KEY (`transacao_id`),
  ADD KEY `ingrediente_id` (`ingrediente_id`),
  ADD KEY `funcionario_id` (`funcionario_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categoriascardapio`
--
ALTER TABLE `categoriascardapio`
  MODIFY `categoria_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `clientes`
--
ALTER TABLE `clientes`
  MODIFY `cliente_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `componentesreceita`
--
ALTER TABLE `componentesreceita`
  MODIFY `receita_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `feedback_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `fornecedores`
--
ALTER TABLE `fornecedores`
  MODIFY `fornecedor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `funcionarios`
--
ALTER TABLE `funcionarios`
  MODIFY `funcionario_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ingredientes`
--
ALTER TABLE `ingredientes`
  MODIFY `ingrediente_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `itenscardapio`
--
ALTER TABLE `itenscardapio`
  MODIFY `item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `itenspedido`
--
ALTER TABLE `itenspedido`
  MODIFY `item_pedido_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `itenspromocao`
--
ALTER TABLE `itenspromocao`
  MODIFY `item_promocao_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `mesas`
--
ALTER TABLE `mesas`
  MODIFY `mesa_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `pedido_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `promocoes`
--
ALTER TABLE `promocoes`
  MODIFY `promocao_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `reservas`
--
ALTER TABLE `reservas`
  MODIFY `reserva_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `transacoesestoque`
--
ALTER TABLE `transacoesestoque`
  MODIFY `transacao_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `componentesreceita`
--
ALTER TABLE `componentesreceita`
  ADD CONSTRAINT `componentesreceita_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `itenscardapio` (`item_id`),
  ADD CONSTRAINT `componentesreceita_ibfk_2` FOREIGN KEY (`ingrediente_id`) REFERENCES `ingredientes` (`ingrediente_id`);

--
-- Constraints for table `feedback`
--
ALTER TABLE `feedback`
  ADD CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`pedido_id`),
  ADD CONSTRAINT `feedback_ibfk_2` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`cliente_id`);

--
-- Constraints for table `ingredientes`
--
ALTER TABLE `ingredientes`
  ADD CONSTRAINT `fk_fornecedor` FOREIGN KEY (`fornecedor_id`) REFERENCES `fornecedores` (`fornecedor_id`);

--
-- Constraints for table `itenscardapio`
--
ALTER TABLE `itenscardapio`
  ADD CONSTRAINT `itenscardapio_ibfk_1` FOREIGN KEY (`categoria_id`) REFERENCES `categoriascardapio` (`categoria_id`);

--
-- Constraints for table `itenspedido`
--
ALTER TABLE `itenspedido`
  ADD CONSTRAINT `itenspedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`pedido_id`),
  ADD CONSTRAINT `itenspedido_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `itenscardapio` (`item_id`);

--
-- Constraints for table `itenspromocao`
--
ALTER TABLE `itenspromocao`
  ADD CONSTRAINT `itenspromocao_ibfk_1` FOREIGN KEY (`promocao_id`) REFERENCES `promocoes` (`promocao_id`),
  ADD CONSTRAINT `itenspromocao_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `itenscardapio` (`item_id`);

--
-- Constraints for table `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`cliente_id`),
  ADD CONSTRAINT `pedidos_ibfk_2` FOREIGN KEY (`funcionario_id`) REFERENCES `funcionarios` (`funcionario_id`);

--
-- Constraints for table `reservas`
--
ALTER TABLE `reservas`
  ADD CONSTRAINT `reservas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`cliente_id`);

--
-- Constraints for table `transacoesestoque`
--
ALTER TABLE `transacoesestoque`
  ADD CONSTRAINT `transacoesestoque_ibfk_1` FOREIGN KEY (`ingrediente_id`) REFERENCES `ingredientes` (`ingrediente_id`),
  ADD CONSTRAINT `transacoesestoque_ibfk_2` FOREIGN KEY (`funcionario_id`) REFERENCES `funcionarios` (`funcionario_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
