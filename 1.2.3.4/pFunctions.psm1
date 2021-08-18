using module ./PClass.psm1

<#
.SYNOPSIS
Performs Read Query to PostgreSQL Database
.DESCRIPTION
Performs Read Query to PostgreSQL Database.  See Notes.
.PARAMETER Credential
Param Info
.PARAMETER Database
Param Info
.PARAMETER Driver
Param Info
.PARAMETER Port
Param Info
.PARAMETER Password
Param Info
.PARAMETER Query
Param Info
.PARAMETER Server
Param Info
.PARAMETER User
Param Info
.NOTES
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
        [Parameter(
            Mandatory = $true,
            ParameterSetName = "encrypt",
            ValueFromPipeline = $true )]
        [PSCredential] $Credential,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String] $Database,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateSet(
            "{PostgreSQL Unicode(x64)}",
            "{PostgreSQL Unicode}",
            "{PostgreSQL ANSI(x64)}",
            "{PostgreSQL ANSI}")]
        [String] $Driver = "{PostgreSQL Unicode(x64)}",

        [Parameter(
            Mandatory = $false,
            ParameterSetName = "clear",
            ValueFromPipeline = $true )]
        [string] $Pswd,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,65355)]
        [int32] $Port = 5432,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true )]
        [String] $Query,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String] $Server,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = "clear",
            ValueFromPipeline = $true)]
        [string] $User = "postgres"
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





<#
.SYNOPSIS
Short description
.DESCRIPTION
Long description
.PARAMETER
Param Info
.PARAMETER
Param Info
.NOTES
.EXAMPLE
Example of how to use this cmdlet
.EXAMPLE
Another example of how to use this cmdlet
.INPUTS
Inputs to this cmdlet (if any)
.OUTPUTS
Output from this cmdlet (if any)
#>
function Set-PostgresData
{
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'high')]

    Param
    (
        [Parameter(
            Mandatory = $true,
            ParameterSetName = "encrypt",
            ValueFromPipeline = $true )]
        [PSCredential] $Credential,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String] $Database,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName=$true)]
        [ValidateSet(
            "{PostgreSQL Unicode(x64)}",
            "{PostgreSQL Unicode}",
            "{PostgreSQL ANSI(x64)}",
            "{PostgreSQL ANSI}")]
        [String] $Driver = "{PostgreSQL Unicode(x64)}",

        [Parameter(
            Mandatory = $false,
            ParameterSetName = "clear",
            ValueFromPipeline = $true )]
        [string] $Pswd,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1,65535)]
        [int32] $Port = 5432,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true )]
        [String] $Query,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [String] $Server,

        [Parameter(
            Mandatory = $false,
            ParameterSetName = "clear",
            ValueFromPipeline = $true)]
        [string] $User = "postgres"
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
        if ($PSCmdlet.ShouldProcess($Database, $Query)) {

            $c = [System.Data.Odbc.OdbcConnection]::new()
            $c.ConnectionString = $ConnString

            try {
                $c.open()
            }
            catch {
                Write-Output "`n"$([Pgres]::mesg1)
                Write-Output $PSItem
                break
            }

            $d = [System.Data.Odbc.OdbcCommand]::new($query,$c)

            try {
                [void] $d.ExecuteNonQuery()
            }
            catch {
                Write-Output "`n"$([Pgres]::mesg2)
                Write-Output $PSItem
            }
            finally {
                $c.close()
            }
        }
    }
}