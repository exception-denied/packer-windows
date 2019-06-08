<powershell>

winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow

net stop winrm
sc config winrm start=auto
net start winrm

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

$region = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/placement/availability-zone

$region = $region.Substring(0,$region.Length-1)

$instance_id = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id

Send-SSMCommand -DocumentName "AmazonInspector-ManageAWSAgent" -InstanceId $instance_id -Region $region

Send-SSMCommand -DocumentName "AWS-ConfigureAWSPackage" -Parameter @{ "action" = "Install"; "name" = "AmazonCloudWatchAgent"; "version" = "latest"} -InstanceId $instance_id -Region $region


</powershell>