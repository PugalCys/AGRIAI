Set-Location "B:\crop analyes\agriguard"
$log = "B:\crop analyes\.freebuff\preview-02e6d9dd-f57b-4868-9974-ba19c61c1c98.log"
$err = "B:\crop analyes\.freebuff\preview-02e6d9dd-f57b-4868-9974-ba19c61c1c98.log.err"
$proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c","node node_modules/vite/bin/vite.js --port 3000 --host" -WorkingDirectory "B:\crop analyes\agriguard" -RedirectStandardOutput $log -RedirectStandardError $err -WindowStyle Hidden -PassThru
Write-Output $proc.Id
