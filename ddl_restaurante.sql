create database db_restaurante;

use  db_restaurante;

create table tb_cliente(
	id int not null auto_increment,
    nome_completo varchar(100) not null,
    numero_telefone varchar(12)not null, 
    endereco_email varchar(100),
    primary key (id)
);

create table tb_cardapio(
	id int not null auto_increment,
    item_cardapio_nome varchar(100) not null,
    item_cardapio_descricao varchar(200), 
    item_cardapio_preco float,
    item_cardapio_categoria varchar(100),
 primary key (id)
);

create table tb_status_reserva(
	id int not null auto_increment,
    nome_status_reserva varchar(100) not null,
    data_hora_status_reserva datetime, 
    primary key (id)
);

create table tb_mesa(
	id int not null auto_increment,
    numero_quantidade_mesa int not null,
    id_status_reserva int,
    primary key (id),
    foreign key(id_status_reserva)
				references tb_status_reserva(id)
);

create table tb_status_pedido(
	id int not null auto_increment,
    status varchar(100),
    nome_cliente_status_pedido varchar(100) not null,
    nome_item_status_pedido varchar(100), 
    quantidade_item_status_pedido int,
    data_hora_status_pedido timestamp default current_timestamp ,
    primary key (id)
);

create table tb_pedido(
	id int not null auto_increment,
    id_status_reserva int,
    id_mesa int,
    primary key (id),
	foreign key(id_status_reserva )
			references tb_status_reserva(id),
	foreign key(id_mesa )
				references tb_mesa(id)
);

create table historico_pedido (
    id int not null auto_increment,
    id_pedido int,
    status_anterior varchar(20),
    status_novo varchar(20),
    data_alteracao timestamp default current_timestamp,
    primary key(id),
    foreign key(id_pedido) 
				references tb_pedido(id)
);


create index idx_nome on tb_cliente(nome_completo);

create unique index idx_telefone on tb_cliente(numero_telefone);

create index idx_nome_telefone on tb_cliente(nome_completo,numero_telefone);

delimiter $$
	create trigger trg_pedido_update
		after update on tb_status_pedido
		for each row
		begin
			if old.status <> new.status then 
				insert into historico_pedido (id,status_anterior,status_novo )
                values (old.id, old.status, new.status);
				end if;
		end $$
        
-- Inserindo um pedido
INSERT INTO tb_status_pedido (nome_cliente_status_pedido, nome_item_status_pedido, status) VALUES ("Joâo","Pizza", 'Pendente');

-- Atualizando o status do pedido
UPDATE tb_status_pedido SET status = 'Enviado' WHERE id = 1;

-- Verificando o histórico
SELECT * FROM historico_pedido WHERE id_pedido = 1;

delimiter $$
	create procedure adicionar_cliente(
		in 	p_nome_completo varchar(100),
		in	p_numero_telefone varchar(12), 
		in	p_endereco_email varchar(100),
        out p_id int
    )
	begin insert into tb_cliente(nome_completo,numero_telefone,endereco_email)
    values (p_nome_completo,p_numero_telefone,p_endereco_email);
	
    set p_id = last_insert_id();
    end$$

-- Declarando uma variável para receber o ID
SET @novo_id = 0;

-- Chamando a procedure
CALL adicionar_cliente('Maria Souza', '81992996014', "maria.souza@example.com", @novo_id);

-- Obtendo o ID do novo cliente
SELECT @novo_id;

