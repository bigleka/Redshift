-- Imagine o seguinte cenário:
-- - Você usa o Redshift como DW ou DL para seus relatório e cargas de dados;
-- - Vê uma possibilidade de facilitar sua vida e dar liberdade para o próprio cliente acessar esses dados e gerar relatórios da forma que ele achar mais legal com a ferramenta que ele quiser, etc.;
-- - Mas lembra que a AWS cobra pela saída de dados;
-- - Procura no portal da AWS e descobre que eles não tem uma monitoração específica de quem está saindo com dados, mas eles acertam a cobrança… incrível…
-- - Mas você não quer abandonar a ideia e quer ganhar alguma grana com isso..
-- O que vou mostrar não é a solução perfeita, ela carece de algumas melhorias mas já é um norte para ajudar nessa ideia…
-- O Redshift é um PostgreSQL modificado, então muita query em tabelas de sistema do PG funciona direitinho no Redshift…
-- Para esse cenário, você pode criar um pacote de integration services e rodar a query abaixo contra o Redshift:
-- https://leka.com.br/2021/03/18/aws-redshift-trafego-de-dados/
select
	TRIM(q.DATABASE) AS DB,
	TRIM(u.usename) as usename,
	sum(bytes)/1024 as kbytes,
	sum(packets) as packets,
	date(b.starttime) as data
from
	stl_bcast b
join stl_query q ON
	b.query = q.query
	AND b.userid = q.userid
join pg_user u
on u.usesysid = q.userid
where
	packets>0
	and b.starttime >= dateadd(day, -7, current_Date)
	and datediff(seconds, b.starttime, b.endtime)>0
	--and u.usename like 'usr%'
	--and querytxt not like 'fetch%'
group by TRIM(q.DATABASE)
,u.usename
,date(b.starttime)

