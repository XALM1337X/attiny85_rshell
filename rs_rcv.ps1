#Import-Module .\test.psm1
#Test-ModuleFunc -Thing "Hello world"


if (!$(Get-NetFirewallRule -DisplayName "rs1in" 2>$null)) {
	New-NetFirewallRule -DisplayName "rs1in" -Direction Inbound -LocalPort 1337 -Protocol TCP -Action Allow
} else {
	Write-Output "Rule already exists";
}

if (!$(Get-NetFirewallRule -DisplayName "rs1out" 2>$null)) {
	New-NetFirewallRule -DisplayName "rs1out" -Direction Outbound -LocalPort 1337 -Protocol TCP -Action Allow
} else {
	Write-Output "Rule already exists";
}




$enc = [system.Text.Encoding]::UTF8
# Set up endpoint and start listening	
$endpoint = new-object System.Net.IPEndPoint([ipaddress]::any, 1337) 
$server = new-object System.Net.Sockets.TcpListener $endpoint
$exit = 0
[System.Net.Sockets.TcpClient[]]$ClientsTaskArr;



Try { 	
	Write-Output "Booting server...";
	$server.Start();		
}
Catch {
	Write-Output $_;
	return;
}


Write-Output "Waiting for client...";
#Listen for Client connections in a loop
while ($exit -eq 0) {
	if ($server.Pending()){
		$client = $server.AcceptTcpClient() 
		Write-Output $client;
	}
	Write-Output "Tick";
	Start-Sleep -Seconds 1.5
}

Write-Output "Client Connected...";
# Stream setup
$stream = $client.GetStream() 
$writer = New-Object System.IO.StreamWriter($stream)
$out_str = "HELLO BACK HACKS!";
$out_bytes = $enc.GetBytes($out_str);
$writer.WriteLine($out_str);
$writer.Flush();

# Close TCP connection and stop listening
$stream.Dispose();
#$client.Close();
$server.Stop();