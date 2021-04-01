select 
	tb1.table_name,
	columns,
	num_rows
from (select 
	       tab.name as table_name, 
	       p.rows as num_rows
	  from sys.tables tab
	       inner join (select distinct 
	                          p.object_id,
	                          sum(p.rows) rows
	                     from sys.tables t
	                          inner join sys.partitions p 
	                              on p.object_id = t.object_id 
	                    group by p.object_id,
	                          p.index_id) p
	            on p.object_id = tab.object_id
	        left join sys.extended_properties ep 
	            on tab.object_id = ep.major_id
	           and ep.name = 'MS_Description'
	           and ep.minor_id = 0
	           and ep.class_desc = 'OBJECT_OR_COLUMN'
	where schema_name(tab.schema_id) = 'dbo') tb1
inner join (select 
			       tab.name as table_name, 
			       count(*) as columns
			from sys.tables as tab
			       inner join sys.columns as col
			           on tab.object_id = col.object_id 
			where  schema_name(tab.schema_id) = 'dbo' 
			group by 
			       tab.name) tb2 on tb1.table_name = tb2.table_name