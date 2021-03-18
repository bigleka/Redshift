-- Normalmente quando os objetos são criados no Redshift ele ficam armazenados no schema public.
-- Isso não é um problema, o problema começa quando é criado um schema para armazenar um outro conjunto de objetos
-- para um setor da empresa, ou um outro departamento...
-- Quando isso acontece, o usuário owner da carga dos objetos tem acesso a essa estrutura de dados sem problema, mas novos usuários,
-- ou usuários permissonalizados não tem a permissão para os objetos ou para novos objetos nesse schema.
-- O script abaixo tente a sanar um cenário em que você quer liberar o acesso de select para os objetos e novo objetos em um schema pulic
-- ou personalizado sem ter que ficar dando grant toda a vez que novos objetos são criados.
-- Outra opção de uso é caso você tenha um Redshift na sua empresa e venda como serviço ele como datalake para algum cliente.
-- dessa forma você consegue liberar um usuário para que o cliente acesse a estrutura de dados e consiga baixar os dados.
-- https://leka.com.br/2021/03/17/aws-redshift-usuario-para-leituras/

-- criar um usuário
create user <username> with password ‘<password>’;

-- cria um grupo para receber as permissões
create group data_viewers;

-- adiciona o usuário ao grupo
alter group data_viewers add user <username>;

-- nesse caso remove a opção de criar objetos para os usuários do grupo
revoke create on schema public from group data_viewers;

-- atribui acesso no schema public ao grupo
grant usage on schema public to group data_viewers;

-- atribui select em todas as tabelas do schema public para o grupo
grant select on all tables in schema public to group data_viewers;

-- atribui acesso a futuros objetos do schema public para o grupo
alter default privileges in schema public grant select on tables to group data_viewers
