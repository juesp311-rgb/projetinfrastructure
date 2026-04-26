# Supprimer toutes les règles existantes sur le port 8443
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*8443*"} | Remove-NetFirewallRule

# Recréer la règle restreinte à la DMZ uniquement
New-NetFirewallRule -DisplayName "HTTPS-8443-DMZ-Only" -Direction Inbound -Protocol TCP -LocalPort 8443 -RemoteAddress "192.168.100.0/24" -Action Allow -Profile Any -Enabled True

# Vérification
Write-Host "--- Verification RemoteAddress ---"
Get-NetFirewallRule -DisplayName "HTTPS-8443-DMZ-Only" | Get-NetFirewallAddressFilter | Select-Object RemoteAddress
