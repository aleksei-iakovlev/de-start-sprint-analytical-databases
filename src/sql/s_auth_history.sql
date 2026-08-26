DROP TABLE IF EXISTS VT260818936815__DWH.s_auth_history;

CREATE TABLE VT260818936815__DWH.s_auth_history
(
hk_l_user_group_activity bigint not null 
	CONSTRAINT fk_s_auth_history_user_group_activity 
	REFERENCES VT260818936815__DWH.l_user_group_activity (hk_l_user_group_activity),
user_id_from int,
event varchar(20) NOT NULL,
event_dt timestamp NOT NULL,
load_dt datetime,
load_src varchar(20)
)
order by load_dt
SEGMENTED BY hk_l_user_group_activity all nodes
PARTITION BY load_dt::date
GROUP BY calendar_hierarchy_day(load_dt::date, 3, 2);

INSERT INTO VT260818936815__DWH.s_auth_history(hk_l_user_group_activity, user_id_from,event,event_dt,load_dt,load_src)
select 
	luga.hk_l_user_group_activity,
	gl.user_id_from,
	gl.event,
	gl.datetime AS event_dt,
	now() AS load_dt,
	's3' AS load_src
from VT260818936815__STAGING.group_log as gl
left join VT260818936815__DWH.h_groups as hg on gl.group_id = hg.group_id
left join VT260818936815__DWH.h_users as hu on gl.user_id = hu.user_id
left join VT260818936815__DWH.l_user_group_activity as luga on hg.hk_group_id = luga.hk_group_id and hu.hk_user_id = luga.hk_user_id
;