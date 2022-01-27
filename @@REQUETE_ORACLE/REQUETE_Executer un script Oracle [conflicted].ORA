
Executer un script Oracle : 

1. Ouvrir un SQL*Plus dans une invite de commandes
====> sqlplus /nolog

2. Se connecter à la base CRYDFRP avec le compte applicatif crydfr sinon tu vas créer les objets sous le compte sys ou system, et grosse galère pour supprimer les objets créés par erreur.
====> connect crydfr/Qual1ta1r30.@crydfrt

3. Vérifier la conexion à la bonne db. Le système doit te retourner CRYDFR ou crydfr à l’exécution de la commande suivante :
====> show user  

4. Coller les scripts du client dans le répertoire g:\oracle

5. Ouvrir chaque script SQL fourni par le client et y ajouter les lignes suivantes : 
====> spool g:\oracle\DDS_ITF_DFR_RAA_IN.log au début du script 
====> spool off à la fin.
====> spool g:\oracle\DDS_ITF_DFR_RAA_OUT.log au début du script 
====> spool off à la fin.

6. ExécuteR les scripts SQL :
====> @D:\Oracle\UTL.sql
====> @g:\oracle\DDS_ITF_DFR_RAA_OUT.sql

7. Tu vérifies dans les logs que tu ne trouves pas d’erreurs Oracle sur l’occurrence « ORA- »


Contournement accès au db oracle sans authentification : 

- Mettre en maintenance la base sur Zabbix 
- Ouvre le fichier sqlnet.ora qui se trouve dans d:\oracle\product\11.2.0\network\admin
- Mets un # devant la ligne sqlnet.authentication
- Reteste une connexion sous crydfr
- Supprimer le # devant la ligne sqlnet.authentication
- Enlever la maintenance de la base sur Zabbix
