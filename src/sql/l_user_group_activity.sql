DROP TABLE IF EXISTS VT260818936815__DWH.l_user_group_activity;

CREATE TABLE VT260818936815__DWH.l_user_group_activity
(
hk_l_user_group_activity int PRIMARY KEY,
hk_user_id int NOT NULL CONSTRAINT fk_l_user_group_activity_user REFERENCES VT260818936815__DWH.h_users (hk_user_id),
hk_group_id int NOT NULL CONSTRAINT fk_l_user_group_activity_group REFERENCES VT260818936815__DWH.h_groups (hk_group_id),
load_dt datetime,
load_src varchar(20)
)
order by load_dt
SEGMENTED BY hk_l_user_group_activity all nodes
PARTITION BY load_dt::date
GROUP BY calendar_hierarchy_day(load_dt::date, 3, 2)
;

INSERT INTO VT260818936815__DWH.l_user_group_activity(hk_l_user_group_activity, hk_user_id,hk_group_id,load_dt,load_src)
select distinct
hash(hg.hk_group_id,hu.hk_user_id),
hu.hk_user_id,
hg.hk_group_id,
now() as load_dt,
's3' as load_src
from VT260818936815__STAGING.group_log as gl
left join VT260818936815__DWH.h_users hu ON gl.user_id = hu.user_id
left join VT260818936815__DWH.h_groups hg ON gl.group_id = hg.group_id
;