class Pgres
{
    static $mesg1 = 'Terminating.  Connection Error.'
    static $mesg2 = 'Error Processing Query.'

    static [string] MakeConnString (
        [string] $Server,
        [int32] $Port,
        [string] $Database,
        [string] $Driver,
        [PSCredential] $Credential
    )
    {
        $user = $Credential.UserName
        $pswd = $Credential.GetNetworkCredential().Password
        $ConnString = (
            "Driver=$Driver;
            Server=$Server;
            Port=$Port;
            Database=$Database;
            Uid=$user;
            Pwd=$pswd;"
        )
        Return $ConnString
    }

    static [string] MakeConnString (
        [string] $Server,
        [int32] $Port,
        [string] $Database,
        [string] $Driver,
        [string] $User,
        [string] $Pswd
        )
    {
        $ConnString = (
            "Driver=$Driver;
            Server=$Server;
            Port=$Port;
            Database=$Database;
            Uid=$user;
            Pwd=$Pswd;"
        )
        Return $ConnString
    }
}