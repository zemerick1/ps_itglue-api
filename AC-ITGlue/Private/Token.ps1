function Get-ArubaCLTokenStatus {
    $expire = $DefaultArubaCLConnection.token.expire 
    $now = [int]((Get-Date -UFormat %s) -split ",")[0]
    if (($expire - $now) -le 0) {
        # If token is expired, it should fail boolean
        return $false
    } else { return $true }
}