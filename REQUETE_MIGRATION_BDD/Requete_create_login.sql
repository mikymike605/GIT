/* sp_help_revlogin script 
** Generated Jun  7 2022  3:17PM on PROSQL01 */
 
 
---- Login: ##MS_PolicyTsqlExecutionLogin##
--CREATE LOGIN [##MS_PolicyTsqlExecutionLogin##] WITH PASSWORD = 0x0200FD8AB0FA0C06434F92FB2BCFB8FE9DE604074CA189F261A87460B732D85416D1EC730B6963400990F63B1CCF314E9A0CE230409934AF724CCD03561BBC9180261A3ACA47 HASHED, SID = 0xA9EEB439F4762546BD90D163703F6DA1, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF; ALTER LOGIN [##MS_PolicyTsqlExecutionLogin##] DISABLE
 
---- Login: PROUDREED\srvllu
--CREATE LOGIN [PROUDREED\srvllu] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROBDD03\Administrator
CREATE LOGIN [PROBDD03\Administrator] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\srvahu
--CREATE LOGIN [PROUDREED\srvahu] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\srvvle
--CREATE LOGIN [PROUDREED\srvvle] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NT SERVICE\SQLWriter
--CREATE LOGIN [NT SERVICE\SQLWriter] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NT SERVICE\Winmgmt
--CREATE LOGIN [NT SERVICE\Winmgmt] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NT Service\MSSQLSERVER
--CREATE LOGIN [NT Service\MSSQLSERVER] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NT AUTHORITY\SYSTEM
--CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NT SERVICE\SQLSERVERAGENT
--CREATE LOGIN [NT SERVICE\SQLSERVERAGENT] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: ##MS_PolicyEventProcessingLogin##
--CREATE LOGIN [##MS_PolicyEventProcessingLogin##] WITH PASSWORD = 0x02005AC7EDADF55A780DF945F19AC8842446D0A07A524E40EA057861C27177F8C6F7FB9F72E9B95A3759F9ADD065ABEA0E8F4067702849DC6CE9A21234DD1161D79EC1BCC88F HASHED, SID = 0x24BA17F616DA2249AD0EEA8EC198999E, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF; ALTER LOGIN [##MS_PolicyEventProcessingLogin##] DISABLE
 
---- Login: BUILTIN\Administrators
--CREATE LOGIN [BUILTIN\Administrators] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\GRP_SQL_cluster
--CREATE LOGIN [PROUDREED\GRP_SQL_cluster] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: ADMIN
CREATE LOGIN [ADMIN] WITH PASSWORD = 0x02002E941559836E6DD0BEE843D94BB566BA1132A6345D5C6926927FD3BC5A907194575124FF3D12DC1C9B339A28E26ADA25C705A7203BC174D7356A42181F645B2230C05F1D HASHED, SID = 0x214F15825E1FCC49A9951AB529DD011C, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
---- Login: dd_user
--CREATE LOGIN [dd_user] WITH PASSWORD = 0x020063B2E8D7CABFC023F387B8648685002E49FF11FC96B283B34492E7B3197C49FBE642E76D74DEC8854A6EF270FBE66AC6EE7A6E52975C83C30C96B1F0C5A1F9E5FF044082 HASHED, SID = 0x1A81C4D185941F429C8866DDA457D4F7, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: admphj
CREATE LOGIN [admphj] WITH PASSWORD = 0x0100631F1E43B9E576388D00F0A287800DE0E449CE25FF4BDDA8 HASHED, SID = 0x9F5B087DB1226149918B9B5156B18747, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: asequil
CREATE LOGIN [asequil] WITH PASSWORD = 0x01000C29FE6F93298D187D32B110F6909EF389F84EC4E6D65FDE HASHED, SID = 0x3428A933E034B34BBFCE309C9E1CECB5, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: cognos_user
CREATE LOGIN [cognos_user] WITH PASSWORD = 0x02007DF661706E09C49F812D0E89CE1842803FE1E7977B6B922A117317C3D224C8CC983E5671B620546D75FD39A8BC093CD09AA442991BA87BC32A08191E20FC366EEF9A69C7 HASHED, SID = 0x0509EA6C341EA947970B88BEBC22655D, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: extractor
CREATE LOGIN [extractor] WITH PASSWORD = 0x01006F4EB04459EA93A9F1AD9F772FE2C1CC1B80D9AB5C02DCBC HASHED, SID = 0xFF07C0742097B44EB49542360896EC95, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\_SVC_ARC
CREATE LOGIN [PROUDREED\_SVC_ARC] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\_SVC_CLBDD
CREATE LOGIN [PROUDREED\_SVC_CLBDD] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\_SVC_XEN_INSTALL
CREATE LOGIN [PROUDREED\_SVC_XEN_INSTALL] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\_SVC_XEN5_INSTALL
CREATE LOGIN [PROUDREED\_SVC_XEN5_INSTALL] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\gdupuis
CREATE LOGIN [PROUDREED\gdupuis] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GG_BDD_PHJ_PROD
CREATE LOGIN [PROUDREED\GG_BDD_PHJ_PROD] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GG_BDD_PHJ_TEST
CREATE LOGIN [PROUDREED\GG_BDD_PHJ_TEST] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GRP_APPLIS_Equilibre
CREATE LOGIN [PROUDREED\GRP_APPLIS_Equilibre] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GRP_APPLIS_SNEDA
CREATE LOGIN [PROUDREED\GRP_APPLIS_SNEDA] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GRP_SECURITE_PWFADMIN
CREATE LOGIN [PROUDREED\GRP_SECURITE_PWFADMIN] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GRP_SECURITE_PWFHELPDESK
CREATE LOGIN [PROUDREED\GRP_SECURITE_PWFHELPDESK] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GRP_SECURITE_PWFPOWERUSERS
CREATE LOGIN [PROUDREED\GRP_SECURITE_PWFPOWERUSERS] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\GRP_SECURITE_XEN_ADMIN
CREATE LOGIN [PROUDREED\GRP_SECURITE_XEN_ADMIN] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\kboujbara
CREATE LOGIN [PROUDREED\kboujbara] FROM WINDOWS WITH DEFAULT_DATABASE = [master]; ALTER LOGIN [PROUDREED\kboujbara] DISABLE
 
-- Login: PROUDREED\support-taliance
CREATE LOGIN [PROUDREED\support-taliance] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\usertst
CREATE LOGIN [PROUDREED\usertst] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: vledall
--CREATE LOGIN [vledall] WITH PASSWORD = 0x010058B093BCD759BDB58930E4C974FE4F2EC8391C5A27932E93 HASHED, SID = 0xC759A5CCA70DC346B2766C14F10CBAD7, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: XRT
CREATE LOGIN [XRT] WITH PASSWORD = 0x01000A61E11AD45502769255EAC7B6D5FF6E9ADCD73A72AB4638 HASHED, SID = 0xB98DD90C792B8D47B6C25816BD86CE7C, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: mr_dwh
CREATE LOGIN [mr_dwh] WITH PASSWORD = 0x01008DD3D64FCE29E66A18D9416D881D91ECD84263536B7E109F HASHED, SID = 0xD0703D7817ED2C478B80EB51BCF65298, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\gnoale
CREATE LOGIN [PROUDREED\gnoale] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\srvmbe2
--CREATE LOGIN [PROUDREED\srvmbe2] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: qlikview_usr
CREATE LOGIN [qlikview_usr] WITH PASSWORD = 0x020098C5EA5C14C2787E5511988E1AEA552071D95E3C876B33F19C36944B882534747ADFC63CAAAE8CA63923B69014BDE7E34971E2A6DFC89895AC0D73C2561CB4DB88438E35 HASHED, SID = 0xB44D06AC5EB5904393F2B5F124D885FD, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF
 
-- Login: pwfadmin
CREATE LOGIN [pwfadmin] WITH PASSWORD = 0x0100F4F64A5AE5A357B86078996DCF2AD53247FADD91F3B8936F HASHED, SID = 0x67354BF1998D1D4E9F89F8D3E39C471A, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF
 
-- Login: pwfadmin_rec
CREATE LOGIN [pwfadmin_rec] WITH PASSWORD = 0x010070F98D21827C2BF8E23D5BF1102368F2225862651A4F02D3 HASHED, SID = 0x604C35605B3DB640BB45E7008D7CAF29, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: pwfadmin_prod
CREATE LOGIN [pwfadmin_prod] WITH PASSWORD = 0x01000E2017F981FBAAC31DEE95588925D5222DE655B74CEBB9A2 HASHED, SID = 0x1B468F7582EDBC4DB1B1DCC17A04548F, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
---- Login: docuware
--CREATE LOGIN [docuware] WITH PASSWORD = 0x020001D9218B7E1D25AF3B97EFF1578350BD9C16C865751CD8F4A741ABA56EA997822030564E23FCDF3982F0801EF3CC9A9F047908867E5431DD1EDAA0EA21ECE6ED0DA0BEED HASHED, SID = 0x770A5D22771F47438B4836502DF361CB, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: user_idbtest
CREATE LOGIN [user_idbtest] WITH PASSWORD = 0x01005D8E06A5C43AED23F89FF561C5FBF33BC8C2F74F538EC646 HASHED, SID = 0xF2DFAF617CA1EC4EB2D461A6B53479E0, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: srvnma
CREATE LOGIN [srvnma] WITH PASSWORD = 0x01002D03B7D6FADE4714AEDFBAF772B3D01FA844F2F1AAA89988 HASHED, SID = 0x211A30C6469EF7459317F57089CB9444, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: rescue
CREATE LOGIN [rescue] WITH PASSWORD = 0x020061DD36F88D6590EF05AD18CB6BDE265A72957CA78770816DD5B1EDC6708606F6D1B3075DDAA4A946C46C6477E591942B1888A36F0992A8786E7D0010AEA152BF86A9AA78 HASHED, SID = 0xCF0749EAEDB29A46A10BBCE8D511BF3C, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\_SVC_COGNOS
CREATE LOGIN [PROUDREED\_SVC_COGNOS] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: presta_cognos
CREATE LOGIN [presta_cognos] WITH PASSWORD = 0x01000075F1CB6649CB846FB4C23B7FF3AA214A059910061D7A21 HASHED, SID = 0x4B9B7D29CB489B4BBD1437B42B246CE4, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: cognos_user1
CREATE LOGIN [cognos_user1] WITH PASSWORD = 0x01003B07635E14E7EA0156D3EA8637C8F108CA71CC3BB0295C3D HASHED, SID = 0x8FDCB2E13E2D7046ADCFDF21D0D03F77, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: admin_xatest
CREATE LOGIN [admin_xatest] WITH PASSWORD = 0x01000E056757333C2B46694D90AF7A6DFE968B279ED8B44DF0E0 HASHED, SID = 0x2B2547C38F445144878B8869EAD4DDBB, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: admin_xahom
CREATE LOGIN [admin_xahom] WITH PASSWORD = 0x020039EFC47DBC1862164019FE7E9D4C154BAA78330D02CB9D062B7131FA824CBB035B49CEE2791EB22AB8A8A2FE22F1A43A648A117CEBF4E631DFB1C423913D94AB8A7F67A0 HASHED, SID = 0xD07A6A5937D1ED4CA8FEAAF2C40B433C, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\pcerin
CREATE LOGIN [PROUDREED\pcerin] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: Anaplan_user
CREATE LOGIN [Anaplan_user] WITH PASSWORD = 0x01009E49D70879310E6A23D6067063651FCCC62651DC6E497268 HASHED, SID = 0x0B33F72A7C704A4D83B7FA4247230A52, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\mrobin
CREATE LOGIN [PROUDREED\mrobin] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\docuware
--CREATE LOGIN [PROUDREED\docuware] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: admin_xaprod
CREATE LOGIN [admin_xaprod] WITH PASSWORD = 0x0200E9DE68C16894FFBD333AF7895FDB061C5FC1FE1096965C640A0FB770B2DB81B30CFEE16985988C20A6B455C1A14E6192249EE82C426AADEBDBB02293D75BDC39F3FCDE17 HASHED, SID = 0x957D8E54A41D074BA5574463CB5C8889, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
---- Login: distributor_admin
--CREATE LOGIN [distributor_admin] WITH PASSWORD = 0x02000733F521614038909B1C1F9702E2B4978D66C48B5E485297D97A6ADA374B15482A7265DCF90803751C9BB4F9C78906F66060318BC0C363E94FB56601B2B36CD9B9B66BF5 HASHED, SID = 0xE0A689EAD47FBA41B155249B6782855A, DEFAULT_DATABASE = [master], CHECK_POLICY = ON, CHECK_EXPIRATION = OFF
 
-- Login: myreport
CREATE LOGIN [myreport] WITH PASSWORD = 0x02002A79C93DD42FA46A5002444947DD1EA12A37B85D15D0BDE7E0B6798AFCCB661603A01D4DF6721C53C206190A89D3DAE95542E676522321ED36E022262E28259A54A776DD HASHED, SID = 0x69F28165CC9536498DDEB79BC60E3272, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
---- Login: PROUDREED\srvogu
--CREATE LOGIN [PROUDREED\srvogu] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\tfichoux
CREATE LOGIN [PROUDREED\tfichoux] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\BGS
CREATE LOGIN [PROUDREED\BGS] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: infa_anaplan
CREATE LOGIN [infa_anaplan] WITH PASSWORD = 0x0200FB73DFD35BDE3DD602DA849853C78585AF619E8197A0B65B9312B10CA6E4CBD699794B69D50D9E8D3FEBE517C87E4440F03B78C1AAB10BA94F2328408CC82FDFAC84914C HASHED, SID = 0xCD07BA926B629A4BB30CD7171DB15EE6, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\plemabic
CREATE LOGIN [PROUDREED\plemabic] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\_SVC_XEN715_INSTALL
CREATE LOGIN [PROUDREED\_SVC_XEN715_INSTALL] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\PRODDC001$
CREATE LOGIN [PROUDREED\PRODDC001$] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\srveks
--CREATE LOGIN [PROUDREED\srveks] FROM WINDOWS WITH DEFAULT_DATABASE = [master]; REVOKE CONNECT SQL TO [PROUDREED\srveks]
 
-- Login: PROUDREED\_SVC_Citrix_PVS
CREATE LOGIN [PROUDREED\_SVC_Citrix_PVS] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\_SVC_Citrix_WEM
CREATE LOGIN [PROUDREED\_SVC_Citrix_WEM] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: vuemUser
CREATE LOGIN [vuemUser] WITH PASSWORD = 0x0200197FC64C8CE7B6C9E35DC2CE37E306F6A3398EE51F711D23A20EA208D6575233FC42BC8EF0A3E91F882E4798F350346468CA485309E423746F7383B7B23438102919E30F HASHED, SID = 0xFDF0E37C26BC7D4DB792C72798E6BF7F, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
-- Login: PROUDREED\zlahri
CREATE LOGIN [PROUDREED\zlahri] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: PROUDREED\srvjgo
--CREATE LOGIN [PROUDREED\srvjgo] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\svctalliance
CREATE LOGIN [PROUDREED\svctalliance] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NEOFED\srvmha
--CREATE LOGIN [NEOFED\srvmha] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: NEOFED\srvrra2
CREATE LOGIN [NEOFED\srvrra2] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: PROUDREED\Cegid_servantissimo
CREATE LOGIN [PROUDREED\Cegid_servantissimo] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
-- Login: powerapp
CREATE LOGIN [powerapp] WITH PASSWORD = 0x0200E9E9F5CFC1E7D64EDA79E6E34155CEB9B2E496B7FA3BFD83BEF482563A077F3D39132A14C148F66BE9BA7BDDC4DF1EB703C8719BA569BB1F33FA6486D3BDDF9FD6769F9E HASHED, SID = 0x3585016B4702B74C90F7217172653064, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
 
---- Login: NEOFED\OBSMHAMCHAOU
--CREATE LOGIN [NEOFED\OBSMHAMCHAOU] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NEOFED\OBSahumbert
--CREATE LOGIN [NEOFED\OBSahumbert] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: NEOFED\OBSTRICHARD
--CREATE LOGIN [NEOFED\OBSTRICHARD] FROM WINDOWS WITH DEFAULT_DATABASE = [master]
 
---- Login: sa_proudreed
--CREATE LOGIN [sa_proudreed] WITH PASSWORD = 0x02008EC57CAE8F403F8B3BD8095692054482D3AB6350BF7A9E0CD5469BE7EE60B86751510ED3ED858BF264E3E47D5328A8D317C0DF9DD582AB4DD092B79AC02F1D5B30BC8F80 HASHED, SID = 0xB59A6793F57395429537A6E6CB0D3AB8, DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF





--Rattache login to old database

--ALTER LOGIN [mr_dwh] WITH DEFAULT_DATABASE = [dwh_proudreed]
--ALTER LOGIN [qlikview_usr] WITH DEFAULT_DATABASE = [dwh_proudreed]
--ALTER LOGIN [pwfadmin_rec] WITH DEFAULT_DATABASE = [powerfuse2011_rec]
--ALTER LOGIN [pwfadmin_prod] WITH DEFAULT_DATABASE = [powerfuse2011_prod]
--ALTER LOGIN [user_idbtest] WITH DEFAULT_DATABASE = [IDB_TEST]
--ALTER LOGIN [srvnma] WITH DEFAULT_DATABASE = [data_store_xen5]
--ALTER LOGIN [rescue] WITH DEFAULT_DATABASE = [data_store_xen5]
--ALTER LOGIN [admin_xatest] WITH DEFAULT_DATABASE = [xenapp65_test]
--ALTER LOGIN [admin_xahom] WITH DEFAULT_DATABASE = [xenapp65_hom]
--ALTER LOGIN [PROUDREED\pcerin] WITH DEFAULT_DATABASE = [dwh_proudreed]
--ALTER LOGIN [admin_xaprod] WITH DEFAULT_DATABASE = [xenapp65_prod]
--ALTER LOGIN [myreport] WITH DEFAULT_DATABASE = [dwh_proudreed]
--ALTER LOGIN [infa_anaplan] WITH DEFAULT_DATABASE = [dwh_proudreed]