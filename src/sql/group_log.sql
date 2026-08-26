DROP TABLE IF EXISTS VT260818936815__STAGING.group_log CASCADE;

CREATE TABLE VT260818936815__STAGING.group_log (
	group_id int NOT NULL,
	user_id int NOT NULL,
	user_id_from int,
	event varchar(10),
	datetime timestamp,
    CONSTRAINT fk_group_log_group_id 
        FOREIGN KEY (group_id) 
        REFERENCES VT260818936815__STAGING.groups(id),
    CONSTRAINT fk_group_log_user_id
        FOREIGN KEY (user_id) 
        REFERENCES VT260818936815__STAGING.users(id)
)
ORDER BY group_id, user_id
PARTITION BY datetime::date
GROUP BY calendar_hierarchy_day(datetime::date, 3, 2);