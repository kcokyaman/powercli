# clear-alarmactions script v1
# Kursad Cokyaman tarafından yazılmıştır.
echo ""
echo "Dikkat!!! Bu VMware PowerCLI script vCenter uzerindeki alarm tanimlamalarinda bulunan Alarm Action bilgilerini temizler!!!"
echo ""
#Baglanilacak vCenter bilgileri
$vc = read-host "Baglanilacak vCenter Hostname/IP: "

#Baglanti kur
$vccon = connect-viserver $vc

#Alarm Definition bilgilerini al
$alarmdef = Get-AlarmDefinition | %{ $_.ToString().Split(',')[0]; }

#Dongu baslar
$alarmdef | ForEach-Object {
	Get-AlarmDefinition $_ | Get-AlarmAction | Remove-AlarmAction -Confirm:$false
}
Disconnect-VIServer $vc