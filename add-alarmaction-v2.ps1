# add-alarmaction script v2
# Kursad Cokyaman tarafından yazılmıştır.
echo ""
echo "Bu VMware PowerCLI script vCenter uzerindeki alarm tanimlamalarina email ile notification trigger 'i ekler!"
echo ""

$x = @()

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Definition Listesi"
$objForm.Size = New-Object System.Drawing.Size(400,400) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True

$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {
        foreach ($objItem in $objListbox.SelectedItems)
            {$x += $objItem}
        $objForm.Close()
    }
    })

$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(225,320)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"

$OKButton.Add_Click(
   {
        foreach ($objItem in $objListbox.SelectedItems)
            {$x += $objItem}
        $objForm.Close()
   })

$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(300,320)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(380,20) 
$objLabel.Text = "Listeden alarmAction eklenecek tanımları CTRL 'a basılı tutarak seciniz:"
$objForm.Controls.Add($objLabel) 

$objListbox = New-Object System.Windows.Forms.Listbox 
$objListbox.Location = New-Object System.Drawing.Size(10,40) 
$objListbox.Size = New-Object System.Drawing.Size(360,220) 

$objListbox.SelectionMode = "MultiExtended"

# Baglanilacak vCenter bilgileri
$vc = read-host "Baglanilacak vCenter Hostname/IP: "

# Baglanti kur
$vccon = connect-viserver $vc

# mail adresi al
$mail = read-host "E-Mail adresi: "

# Alarm Definition bilgilerini al
$alarmdef = Get-AlarmDefinition | %{ $_.ToString().Split(',')[0]; }
$alarmdef | ForEach-Object {
	[void] $objListbox.Items.Add($_)
}
$objListbox.Height = 270
$objForm.Controls.Add($objListbox) 
$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$x | ForEach-Object {
	Get-AlarmDefinition $_ | New-AlarmAction -Email -To $mail
	Get-AlarmDefinition $_ | Get-AlarmAction | New-AlarmActionTrigger -StartStatus 'Red' -EndStatus 'Yellow'
	Get-AlarmDefinition $_ | Get-AlarmAction | New-AlarmActionTrigger -StartStatus 'Yellow' -EndStatus 'Green'
	Get-AlarmDefinition $_ | Get-AlarmAction | New-AlarmActionTrigger -StartStatus 'Green' -EndStatus 'Yellow'
# 	Default config ile bu trigger ekli geliyor yine de burada bulunsun :)
#	Get-AlarmDefinition $_ | Get-AlarmAction | New-AlarmActionTrigger -StartStatus 'Yellow' -EndStatus 'Red'
}

Disconnect-VIServer $vc

#Raporlama
echo ""
echo "Aktif edilen definitionlar :"
$x