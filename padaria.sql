-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 05/05/2025 às 21:44
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `padaria_views,procedures`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `atualizar_status_por_id` (IN `p_status` CHAR, IN `p_ids` TEXT)   begin 
  -- variaveis para loop
declare id_cliente int;
declare pos_in int default 1;
declare pos_virg int;

repeticao: loop
set pos_virg = locate(',', p_ids, pos_in);
if pos_virg =0 THEN
	set id_cliente = cast(substring(p_ids, pos_in) as unsigned);
else 
	set id_cliente = cast(substring(p_ids, pos_in, pos_virg - pos_in) as unsigned);
end if;

update clientes set status=p_status where id=id_cliente;
        
  -- Se não houver mais vírgula, sai do loop
if pos_virg = 0 THEN
leave repeticao;
end if;
  -- Atualiza a posição inicial para o próximo ID
set pos_in = pos_virg +1;
end loop;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `atualizar_telefone_cliente` (IN `p_id` INT, IN `p_telefone` VARCHAR(15))   begin update clientes set telefone=p_telefone where id = p_id;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_cliente_por_nome` (IN `p_nome` VARCHAR(100))   begin select *from clientes where nome like('%',p_nome,'%');
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calcular_media_idades` (OUT `media` DECIMAL(5,2))   begin select avg(timestampdiff(year, nascimento, current_date())) into media from clientes;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `excluir_cliente` (IN `p_id` INT)   begin delete from clientes where id=p_id;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inserir_cliente` (IN `p_nome` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_telefone` VARCHAR(15))   BEGIN INSERT INTO clientes(nome, email, telefone) values (p_nome, p_email, p_telefone);
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_clientes` ()   begin SELECT * from clientes;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `listar_clientes_inativos` ()   begin select * from clientes where status like'i';
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura para tabela `clientes`
--
-- Criação: 05/04/2025 às 18:44
--

CREATE TABLE `clientes` (
  `id` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `nascimento` date NOT NULL,
  `telefone` varchar(15) NOT NULL,
  `status` varchar(7) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `clientes`
--

INSERT INTO `clientes` (`id`, `nome`, `email`, `nascimento`, `telefone`, `status`) VALUES
(2, 'Uzias', 'Marco@gmail', '0000-00-00', '9999999', 'I'),
(3, 'Ozaliet', 'Oz@gmail.com', '1111-11-11', '444444444', 'A'),
(4, 'Sadraque', 'sadraque@gmail.com', '2002-08-20', '(44) 44444-4444', 'A'),
(5, 'Daniel', 'daniel@gmail.com', '2002-07-21', '(55) 55555-5555', 'I'),
(6, 'Misael', 'misael@gmail.com', '2002-05-12', '(66) 66666-6666', 'A'),
(7, 'Urias', 'urias@gmail.com', '2008-07-22', '(77) 77777-7777', 'A'),
(8, 'Rute', 'rute123@gmail.com', '2007-03-15', '(88) 88888-8888', 'I'),
(9, 'Ester', 'ester@gmail.com', '1995-09-22', '(99) 99999-9999', 'A'),
(10, 'Finéias', 'fineias@gmail.com', '1997-04-17', '(10) 11010-1010', 'A');

--
-- Acionadores `clientes`
--
DELIMITER $$
CREATE TRIGGER `antes_excluir_cliente` BEFORE DELETE ON `clientes` FOR EACH ROW begin declare pedidos_pendentes int;
select count(*) into pedidos_pendentes from vendas where id_cliente = old.id and status = 'Pendente';
if pedidos_pendentes >0 then signal sqlstate '45000'
	set message_text = 'Desculpe, não é permitido excluir o cadastro de clientes com pedidos pendentes!';
end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `clientes_ativos`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `clientes_ativos` (
`id` int(11)
,`nome` varchar(100)
,`email` varchar(100)
,`telefone` varchar(15)
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `pedidos`
--
-- Criação: 21/03/2025 às 00:26
--

CREATE TABLE `pedidos` (
  `id_pedido` int(10) NOT NULL,
  `id_cliente` int(10) DEFAULT NULL,
  `data_pedido` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `pedidos_clientes`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `pedidos_clientes` (
`id_pedido` int(10)
,`data_pedido` date
,`id_cliente` int(10)
,`cliente` varchar(100)
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `pedidos_recentes`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `pedidos_recentes` (
`id_pedido` int(10)
,`id_cliente` int(10)
,`data_pedido` date
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `produtos`
--
-- Criação: 08/04/2025 às 22:27
--

CREATE TABLE `produtos` (
  `id_produto` int(11) NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `estoque` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `produtos`
--

INSERT INTO `produtos` (`id_produto`, `nome`, `estoque`) VALUES
(1, 'Notebook HP', 98),
(2, 'Mouse PS2', 237),
(3, 'Pé de Mouse', 300),
(4, 'Mousepad', 49),
(5, 'Mouse PS2', 40),
(6, 'Processador INTEL 486 DX4 100Mhz', 38);

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `total_pedidos_por_cliente`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `total_pedidos_por_cliente` (
`nome` varchar(100)
,`email` varchar(100)
,`cliente` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura para tabela `triggers`
--
-- Criação: 09/04/2025 às 19:35
--

CREATE TABLE `triggers` (
  `nome` varchar(100) DEFAULT NULL,
  `descricao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `triggers`
--

INSERT INTO `triggers` (`nome`, `descricao`) VALUES
('depois_inserir_venda', 'delimiter $$\r\ncreate or replace trigger depois_inserir_venda after insert on vendas\r\nfor each row BEGIN\r\nupdate produtos set estoque=estoque - new.quantidade where id_produto = new.id_produto;\r\nend $$\r\ndelimiter;'),
('antes_excluir_clientes', 'delimiter $$\r\ncreate trigger antes_excluir_cliente before delete on clientes for each row begin declare pedidos_pendentes int;\r\nselect count* into pedidos_pendentes from vendas where id_cliente = old.id_cliente and status = \"Pendente\";\r\nif pedidos_pendentes >0 then signal sqlstate \"45000\" set message_text = \"Desculpe, não é permitido excluir o cadastro de clientes com pedidos pendentes!\";\r\nend if;\r\nend $$\r\ndelimiter;');

-- --------------------------------------------------------

--
-- Estrutura para tabela `vendas`
--
-- Criação: 09/04/2025 às 19:01
--

CREATE TABLE `vendas` (
  `id_venda` int(11) NOT NULL,
  `id_produto` int(11) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `quantidade` int(11) NOT NULL,
  `data_venda` timestamp NOT NULL DEFAULT current_timestamp(),
  `valor` decimal(10,2) DEFAULT NULL,
  `status` enum('Pendente','Concluido') DEFAULT 'Pendente'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `vendas`
--

INSERT INTO `vendas` (`id_venda`, `id_produto`, `id_cliente`, `quantidade`, `data_venda`, `valor`, `status`) VALUES
(1, 1, 3, 2, '2025-04-09 17:37:35', 3200.00, 'Pendente'),
(2, 2, 6, 13, '2025-04-09 17:37:35', 2700.00, 'Pendente'),
(3, 3, 8, 20, '2025-04-09 17:37:35', 1000.00, 'Pendente'),
(4, 4, 7, 1, '2025-04-09 17:43:18', 300.00, 'Pendente'),
(5, 5, 4, 10, '2025-04-09 17:44:08', 100.00, 'Pendente'),
(6, 6, 10, 12, '2025-04-09 17:44:08', 1600.00, 'Pendente');

--
-- Acionadores `vendas`
--
DELIMITER $$
CREATE TRIGGER `depois_inserir_venda` AFTER INSERT ON `vendas` FOR EACH ROW BEGIN
update produtos set estoque=estoque - new.quantidade where id_produto = new.id_produto;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura stand-in para view `vendas_totais`
-- (Veja abaixo para a visão atual)
--
CREATE TABLE `vendas_totais` (
`id_cliente` int(11)
,`total_cliente` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estrutura da view `clientes_ativos` exportado como tabela
--
DROP TABLE IF EXISTS `clientes_ativos`;
CREATE TABLE`clientes_ativos`(
    `id` int(11) NOT NULL DEFAULT '0',
    `nome` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
    `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
    `telefone` varchar(15) COLLATE utf8mb4_general_ci NOT NULL
);

-- --------------------------------------------------------

--
-- Estrutura da view `pedidos_clientes` exportado como tabela
--
DROP TABLE IF EXISTS `pedidos_clientes`;
CREATE TABLE`pedidos_clientes`(
    `id_pedido` int(10) NOT NULL,
    `data_pedido` date NOT NULL,
    `id_cliente` int(10) DEFAULT NULL,
    `cliente` varchar(100) COLLATE utf8mb4_general_ci NOT NULL
);

-- --------------------------------------------------------

--
-- Estrutura da view `pedidos_recentes` exportado como tabela
--
DROP TABLE IF EXISTS `pedidos_recentes`;
CREATE TABLE`pedidos_recentes`(
    `id_pedido` int(10) NOT NULL,
    `id_cliente` int(10) DEFAULT NULL,
    `data_pedido` date NOT NULL
);

-- --------------------------------------------------------

--
-- Estrutura da view `total_pedidos_por_cliente` exportado como tabela
--
DROP TABLE IF EXISTS `total_pedidos_por_cliente`;
CREATE TABLE`total_pedidos_por_cliente`(
    `nome` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
    `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
    `cliente` bigint(21) NOT NULL DEFAULT '0'
);

-- --------------------------------------------------------

--
-- Estrutura da view `vendas_totais` exportado como tabela
--
DROP TABLE IF EXISTS `vendas_totais`;
CREATE TABLE`vendas_totais`(
    `id_cliente` int(11) DEFAULT NULL,
    `total_cliente` decimal(32,2) DEFAULT NULL
);

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `telefone` (`telefone`);

--
-- Índices de tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id_pedido`),
  ADD KEY `fk_pedidos_cliente` (`id_cliente`);

--
-- Índices de tabela `produtos`
--
ALTER TABLE `produtos`
  ADD PRIMARY KEY (`id_produto`);

--
-- Índices de tabela `vendas`
--
ALTER TABLE `vendas`
  ADD PRIMARY KEY (`id_venda`),
  ADD KEY `id_produto` (`id_produto`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de tabela `produtos`
--
ALTER TABLE `produtos`
  MODIFY `id_produto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de tabela `vendas`
--
ALTER TABLE `vendas`
  MODIFY `id_venda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_pedidos_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id`);

--
-- Restrições para tabelas `vendas`
--
ALTER TABLE `vendas`
  ADD CONSTRAINT `vendas_ibfk_1` FOREIGN KEY (`id_produto`) REFERENCES `produtos` (`id_produto`),
  ADD CONSTRAINT `vendas_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
