<powershell>
write-output "Running User Data Script"
write-host "(host) Running User Data Script"

# TODO: User should replace password here with something random. Even better, implement over SSL: https://github.com/packer-community/packer-windows-plugins/issues/30
# Also note, this user should be removed in Cfn Init
cmd.exe /c net user /add packer LameInsecurePassword!123
cmd.exe /c net localgroup administrators packer /add

Set-ExecutionPolicy -ExecutionPolicy bypass -Scope LocalMachine

# RDP
cmd.exe /c netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
cmd.exe /c reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

# WinRM
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm quickconfig '-transport:http'
cmd.exe /c winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="8192"}'
cmd.exe /c winrm set winrm/config/winrs '@{MaxConcurrentUsers="100"}'
cmd.exe /c winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
cmd.exe /c winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
cmd.exe /c winrm set winrm/config '@{MaxTimeoutms="7200000"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTP" '@{Port="5985"}'
cmd.exe /c netsh advfirewall firewall set rule group="remote administration" new enable=yes 
cmd.exe /c netsh firewall add portopening TCP 5985 "Port 5985" 
cmd.exe /c net stop winrm 
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm
cmd.exe /c wmic useraccount where "name='packer'" set PasswordExpires=FALSE

</powershell>
