bcp.exe ODS..ODS_invoicedetail2 in "H:\backup\FG_1.txt" -f "\\aubfrsql2014\H$\backup\FG.FMT"  -T -S AUBFRSQL2014\MSSQLSERVER2014 -b 10000 -h "TABLOCK" -a 65535 -e H:\backup\errorFGin_1.txt
