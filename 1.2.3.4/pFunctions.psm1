using module ./PClass.psm1

<#
.SYNOPSIS
Performs Read Query to PostgreSQL Database
.DESCRIPTION
Performs Read Query to PostgreSQL Database.  See Notes.
.PARAMETER Credential
PSCredential of Database User and Password.  Use in lieu of User & Pswd Parameters.
$MyCreds = Get-Credential.  See Examples.
.PARAMETER Database
PostgreSQL database name.
.PARAMETER Driver
PostgreSQL ODBC driver.  Defaults to {PostgreSQL Unicode(x64)}.  See Notes.
Select one of:  {PostgreSQL Unicode(x64)}, {PostgreSQL Unicode},
{PostgreSQL ANSI(x64)} or {PostgreSQL ANSI}.
.PARAMETER Port
Port number PostgreSQL is listening on.  Defaults to 5432.
.PARAMETER Pswd
Password of database user if Credential parameter is not used.  Not secure.
.PARAMETER Query
SQL Query to execute.  Example:  "SELECT * FROM test_tb_1;"
.PARAMETER Server
Server hosting the target PostgreSQL database.
.PARAMETER User
Database user name if Credential parameter is not used.  Defaults to postgres.
.NOTES
1. Requires installation of postgreSQL ODBC Drivers:
   https://www.postgresql.org/ftp/odbc/versions/msi/
2. More example queries are listed in queries.sql.
3. Postgres tables named 'Item' don't display properly.
.LINK
Get-Credential
https://www.postgresql.org/ftp/odbc/versions/msi/
.EXAMPLE
Ensure postgreSQL ODBC Drivers are installed.  See Notes.

Retrieve records with credentials:

$c = Get-Credential -UserName my_user
$s = 'test1.example.org'
$d = 'test_db'
$q = "SELECT * FROM test_tb_1;"

Get-PostgresData -Server $s -Database $d -Query $q -Credential $c

.EXAMPLE
This example uses variables declared in Example 1 above.

Retrieve records with default user (postgres) and non-default port:

Get-PostgresData -Server $s -Database $d -Query $q -Port 7777

.OUTPUTS
System.Data.DataRow
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
Performs Modify Queries on PostgreSQL Database
.DESCRIPTION
Performs Modify (e.g. Create, Insert, Update, Alter, Delete, Drop, etc.) on PostgreSQL Databases.  See Notes.
.PARAMETER Credential
PSCredential of Database User and Password.  Use in lieu of User & Pswd Parameters.
$MyCreds = Get-Credential.  See Examples.
.PARAMETER Database
PostgreSQL database name.
.PARAMETER Driver
PostgreSQL ODBC driver.  Defaults to {PostgreSQL Unicode(x64)}.  See Notes.
Select one of:  {PostgreSQL Unicode(x64)}, {PostgreSQL Unicode},
{PostgreSQL ANSI(x64)} or {PostgreSQL ANSI}.
.PARAMETER Port
Port number PostgreSQL is listening on.  Defaults to 5432.
.PARAMETER Pswd
Password of database user if Credential parameter is not used.  Not secure.
.PARAMETER Query
SQL Query to execute.  Example:  "CREATE DATABASE test_db;"
.PARAMETER Server
Server hosting the target PostgreSQL database.
.PARAMETER User
Database user name if Credential parameter is not used.  Defaults to postgres.
.NOTES
1. Requires installation of postgreSQL ODBC Drivers:
   https://www.postgresql.org/ftp/odbc/versions/msi/
2. More example queries are listed in queries.sql.
.LINK
Get-Credential
https://www.postgresql.org/ftp/odbc/versions/msi/


.EXAMPLE
Ensure postgreSQL ODBC Drivers are installed.  See Notes.

Declare variables for Examples:

$c = Get-Credential -UserName my_user
$s = 'test1.example.org'
$d = 'test_db'
$p = 'postgres'
$q1 = 'CREATE DATABASE test_db;'
$q2 = 'CREATE TABLE test_tb_1(gadget VARCHAR,amount NUMERIC);'
$q3 = "INSERT INTO test_tb_1(gadget, amount) VALUES ('arrows',20),('skis',10),('SUPs',4);"
$q4 = 'ALTER TABLE test_tb_1 RENAME gadget TO thing;'
$q5 = 'DROP TABLE test_tb_1;'
$q6 = 'DROP DATABASE test_db;'

Create database with credentials:

Set-PostgresData -Server $s -Database $p -Query $q1 -Credential $c

.EXAMPLE
Ensure postgreSQL ODBC Drivers are installed.  See Notes.

This example uses variables declared in Example 1 above.

Create table, insert records, modify table, drop table, drop database:

Set-PostgresData -Server $s -Database $d -Query $q2 -Credential $c
Set-PostgresData -Server $s -Database $d -Query $q3 -Credential $c
Set-PostgresData -Server $s -Database $d -Query $q4 -Credential $c
Set-PostgresData -Server $s -Database $d -Query $q5 -Credential $c
Set-PostgresData -Server $s -Database $p -Query $q6 -Credential $c

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