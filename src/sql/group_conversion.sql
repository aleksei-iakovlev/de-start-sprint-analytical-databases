WITH user_group_messages AS (
SELECT 
	hk_group_id,	
	count(DISTINCT hk_user_id)	AS cnt_users_in_group_with_messages
		FROM VT260818936815__DWH.l_groups_dialogs lgd 
			JOIN VT260818936815__DWH.l_user_message um ON lgd.hk_message_id = um.hk_message_id
		GROUP BY lgd.hk_group_id
), user_group_log AS 
(
SELECT 
	hk_group_id,
	count(DISTINCT luga.hk_user_id) AS cnt_added_users
	FROM VT260818936815__DWH.l_user_group_activity luga
		JOIN VT260818936815__DWH.s_auth_history sah using(hk_l_user_group_activity)
		WHERE sah.event = 'add' 
			AND luga.hk_group_id IN (
				SELECT hk_group_id
					FROM VT260818936815__DWH.h_groups hg 
					ORDER BY registration_dt ASC
					LIMIT 10)
		GROUP BY luga.hk_group_id
)
select 
	ugm.hk_group_id,
	cnt_added_users,
	cnt_users_in_group_with_messages,
	cnt_users_in_group_with_messages / cnt_added_users AS group_conversion
from user_group_messages ugm JOIN user_group_log ugl ON ugm.hk_group_id = ugl.hk_group_id
order by group_conversion desc
;