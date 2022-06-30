function Test-ModuleFunc {
	[CmdletBinding()]
	param (	
		[Parameter(Mandatory)]
		[string]$Thing
	)
	Write-Output $Thing
}