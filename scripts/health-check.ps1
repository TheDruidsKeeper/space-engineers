$securityKey = $env:secret;
if ($securityKey -eq "empty") {
    return -2;
}

$path = "/vrageremote/v1/server/ping";
$nonce = [Random]::new().Next(0, [int]::MaxValue);
$date = [DateTime]::UtcNow.ToString("r", [CultureInfo]::InvariantCulture);

# Build message to hash
$sb = New-Object System.Text.StringBuilder;
$sb.AppendLine($path) | Out-Null;
$sb.AppendLine($nonce) | Out-Null;
$sb.AppendLine($date) | Out-Null;
$message = $sb.ToString();

# Create hash
$messageBytes = [Text.Encoding]::UTF8.GetBytes($message);
$keyBytes = [Convert]::FromBase64String($securityKey);
$hmac = New-Object System.Security.Cryptography.HMACSHA1;
$hmac.Key = $keyBytes;
$computedHash = $hmac.ComputeHash($messageBytes);
$hash = [Convert]::ToBase64String($computedHash);

$auth = "${nonce}:$hash";
$url = "http://localhost:8080$path";
Write-Host Pinging Server...;
$response = Invoke-RestMethod -Uri $url -Headers @{"Authorization"=$auth; "Date"=$date} -Method:Get -ErrorAction:Stop -TimeoutSec 5;

try {
    if ($response.data.Result -eq "Pong") {
        return 0;
    } else {
        return 1;
    }
} catch {
    return 2;
}