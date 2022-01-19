SELECT C.most_recent_session_id
    , C.net_transport
    , CASE net_transport
        WHEN 'session' THEN 1
        ELSE 0
    END AS is_mars
    , C.protocol_type
    , C.auth_scheme
    , S.nt_user_name
    , S.login_name
    , C.connect_time
    , C.last_read
    , C.last_write
    , login_seconds =
    CASE
        WHEN C.last_read > C.last_write THEN datediff(second, C.connect_time, C.last_read)
        WHEN C.last_read < C.last_write THEN datediff(second, C.connect_time, C.last_write)
        ELSE datediff(second, C.connect_time, C.last_write)
    END
    , S.[host_name]
    , S.[program_name]
    , S.is_user_process
    , C.parent_connection_id
    , C.most_recent_sql_handle
    , ST.text
FROM sys.dm_exec_connections AS C
LEFT JOIN sys.dm_exec_sessions AS S
    ON C.most_recent_session_id = S.session_id
    CROSS APPLY sys.dm_exec_sql_text(C.most_recent_sql_handle) AS ST
WHERE S.is_user_process = 1
ORDER BY 1--C.net_transport, C.connect_time