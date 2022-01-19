Commandes exécutées sur la base BFC :

connect db_tuner/'S!a.6!t-0.'@bfc

====> ORA-28000: the account is locked

connect / as sysdba

====> Connected

select account_status from dba_users where username='DB_TUNER';

====> alter user db_tuner identified by "'S!a.6!t-0.'" account unlock;

Tester une connexion sous SQL*Plus avec le user db_tuner

====> connect db_tuner/'S!a.6!t-0.'@bfc

Résultat : ====> connected

Je pense qu’ils ont essayé de se connecter avec ce compte et qu’il s’est locké après trois échecs de connexion ;
