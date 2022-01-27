  
Executer un script Oracle : 

1. Ouvrir un SQL*Plus dans une invite de commandes
====> sqlplus /nolog

2. Se connecter à la base CRYDFRP avec le compte applicatif crydfr sinon tu vas créer les objets sous le compte sys ou system, et grosse galère pour supprimer les objets créés par erreur.
====> connect crydfr/d1shiZLCmk34S!@CRYDFRP

3. Vérifier la conexion à la bonne db. Le système doit te retourner CRYDFR ou crydfr à l’exécution de la commande suivante :
====> show user

4. Coller les scripts du client dans le répertoire g:\oracle

5. Ouvrir chaque script SQL fourni par le client et y ajouter les lignes suivantes : 
/!\ Le "/" à la fin du script doit être avant le "spool off"
====> spool g:\oracle\DDS_ITF_DFR_J2S_IN_pkb.log au début du script 
====> spool off à la fin.
====> spool g:\oracle\DDS_ITF_DFR_J2S_IN_pks.log au début du script 
====> spool off à la fin.

6. ExécuteR les scripts SQL :
====> @g:\Oracle\DDS_ITF_DFR_RAA_IN.sql
====> @g:\oracle\DDS_ITF_DFR_RAA_OUT.sql
REM ====> @g:\Oracle\DDS_ITF_DFR_BO_IN_pkb.sql
REM ====> @g:\oracle\DDS_ITF_DFR_BO_OUT_pkb.sql

7. Tu vérifies dans les logs que tu ne trouves pas d’erreurs Oracle sur l’occurrence « ORA- »


Contournement accès au db oracle sans authentification : 

- Mettre en maintenance la base sur Zabbix 
- Ouvre le fichier sqlnet.ora qui se trouve dans d:\oracle\product\11.2.0\network\admin
- Mets un # devant la ligne sqlnet.authentication
- Reteste une connexion sous crydfr
- Supprimer le # devant la ligne sqlnet.authentication
- Enlever la maintenance de la base sur Zabbix
