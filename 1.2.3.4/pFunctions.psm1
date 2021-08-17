using module ./PClass.psm1

<#
.SYNOPSIS
Short description
.DESCRIPTION
Long description
.PARAMETER
Param Info
.PARAMETER
Param Info
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
.INPUTS
Inputs to this cmdlet (if any)
.OUTPUTS
Output from this cmdlet (if any)
#>
function Get-PostgresData
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory = $true,
            ParameterSetName = "encrypt",
            ValueFromPipeline = $true )]
        [PSCredential] $Credential,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String] $Database,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateSet(
            "{PostgreSQL Unicode(x64)}",
            "{PostgreSQL Unicode}",
            "{PostgreSQL ANSI(x64)}",
            "{PostgreSQL ANSI}")]
        [String] $Driver = "{PostgreSQL Unicode(x64)}",

        [Parameter(Mandatory = $false,
            ParameterSetName = "clear",
            ValueFromPipeline = $true )]
        [string] $Pswd,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,65555)]
        [int32] $Port = 5432,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true )]
        [String] $Query,

        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String] $Server,

        [Parameter(Mandatory = $true,
            ParameterSetName = "clear",
            ValueFromPipeline = $true)]
        [string] $User
    )

    Begin
    {
        if ($Credential) {
            $ConnString = [Pgres]::MakeConnString(
                $Server,
                $Port,
                $Database,
                $Driver,
                $Credential
            )
        }
        else {
            $ConnString = [Pgres]::MakeConnString(
                $Server,
                $Port,
                $Database,
                $Driver,
                $User,
                $Pswd
            )
        }
    }

    Process
    {
        $c = [System.Data.Odbc.OdbcConnection]::new()
        $c.ConnectionString = $ConnString

        try {
            $c.open()
        }
        catch {
            Write-Output "`n"$([Pgres]::mesg1)
            Write-Output $_
            break
        }

        $d = [System.Data.Odbc.OdbcCommand]::new($query,$c)
        $info = [System.Data.DataSet]::new()

        try {
            [void] [System.Data.Odbc.OdbcDataAdapter]::New($d).fill($info)
        }
        catch {
            Write-Output "`n"$([Pgres]::mesg2)
            Write-Output $_
        }
        finally {
            $c.close()
            $info.Tables
        }
    }
}