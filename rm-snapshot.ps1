# remove Snapshot script v1
# Kursad Cokyaman tarafından yazılmıştır.
echo ""
echo "Bu VMware PowerCLI script vCenter uzerindeki kullanici tarafindan belirtilen gunden eski snapshotlari siler!"
echo ""
$sure = read-host "Kac gunden eski snapshotlar silinecek"
$vc= read-host "Baglanilacak vCenter Hostname/IP: "
$vccon = connect-VIserver $vc
$vm=get-vm
$snapshots=get-snapshot $vm
$say=0
Write-Host "Name			 Size			 Created Date"
Write-Host "----			 ----			 ------------"
foreach ($snap in $snapshots) {
	if ( $snap.Created -lt (Get-Date).AddDays( -$sure ) ) {
#	if ( $snap.Name -eq "silinecek" ) {
		Write-Host $snap.Name "		" $snap.SizeMB "		" $snap.Created
		$say = $say + 1
	}
}
$a = new-object -comobject wscript.shell
if ( $say -eq 0 ){
	$intAnswer = $a.popup("Snapshot bulunamadi!", 0,"Uyari",0)
} else {
	$mesaj=$say.tostring() + " adet Snapshot bulundu. Silinsin mi?"
	$intAnswer = $a.popup($mesaj, 0,"Uyari!",4)
	foreach ($snap in $snapshots) {
		if ( $snap.Created -lt (Get-Date).AddDays( -$sure ) ) {
	#	if ( $snap.Name -eq "silinecek" ) {
			if ($intAnswer -eq 6) { 
				remove-snapshot $snap -confirm:$false
			}
		}
	}
}
Disconnect-VIServer $vc