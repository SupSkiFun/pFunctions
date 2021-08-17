static [string] MakeConnString([PSCredential] $Credential)
    {
        $user = $Credential.UserName
        $pswd = $Credential.GetNetworkCredential().Password
        return $auth_hash
    }