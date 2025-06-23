<#
.SYNOPSIS
Entity Framework Core migration helper script

.DESCRIPTION
Manages EF Core migrations for the Orbit project

.PARAMETER Command
The migration command to execute (add, remove, list, up, down, script)

.PARAMETER Arguments
Additional arguments for the command

.EXAMPLE
.\migrate.ps1 add InitialCreate
.\migrate.ps1 up
.\migrate.ps1 down 20230624120000_InitialCreate
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

$ProjectDir = "src/Orbit.Infrastructure"
$MigrationsDir = "Data/Migrations"
$ScriptOutput = "migration_script.sql"

function Show-Help {
    Write-Host "Entity Framework Core Migration Helper"
    Write-Host "Usage: .\migrate.ps1 <command> [arguments]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  add <name>        Create new migration"
    Write-Host "  remove            Remove last pending migration"
    Write-Host "  list              List all migrations"
    Write-Host "  up [migration]    Apply migrations (to latest or specific)"
    Write-Host "  down <migration>  Revert to specific migration"
    Write-Host "  script [from] [to] Generate SQL script"
    Write-Host "  help              Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\migrate.ps1 add InitialCreate"
    Write-Host "  .\migrate.ps1 up"
    Write-Host "  .\migrate.ps1 down 20230624120000_InitialCreate"
    Write-Host "  .\migrate.ps1 script 20230624120000_InitialCreate 20230625140000_UpdateTables"
}

function Run-EF {
    param(
        [string[]]$EFArgs
    )

    $fullCommand = "dotnet ef $($EFArgs -join ' ') --project `"$ProjectDir`""
    Write-Host "Executing: $fullCommand"

    # Set environment variable if connection string exists
    if ($env:DB_CONNECTION) {
        $env:DB_CONNECTION = $env:DB_CONNECTION
    }

    Invoke-Expression $fullCommand
}

function Add-MigrationCmd {
    param(
        [string]$Name
    )

    if (-not $Name) {
        Write-Host "Error: Migration name required" -ForegroundColor Red
        exit 1
    }

    Run-EF "migrations", "add", $Name, "--output-dir", "`"$MigrationsDir`""
}

function Remove-MigrationCmd {
    Run-EF "migrations", "remove"
}

function List-MigrationsCmd {
    Run-EF "migrations", "list"
}

function Update-DatabaseCmd {
    param(
        [string]$Migration
    )

    $args = @("database", "update")
    if ($Migration) { $args += $Migration }

    Run-EF $args
}

function Rollback-MigrationCmd {
    param(
        [string]$TargetMigration
    )

    if (-not $TargetMigration) {
        Write-Host "Error: Target migration name required for rollback" -ForegroundColor Red
        exit 1
    }

    $migrations = Run-EF "migrations", "list" | Where-Object { $_ -match '^\d' }
    $index = [array]::IndexOf($migrations, $TargetMigration)

    if ($index -eq -1) {
        Write-Host "Error: Migration '$TargetMigration' not found" -ForegroundColor Red
        exit 1
    }

    if ($index -eq 0) {
        Write-Host "Error: No migrations before '$TargetMigration'" -ForegroundColor Red
        exit 1
    }

    $prevMigration = $migrations[$index - 1]
    Write-Host "Rolling back to: $prevMigration" -ForegroundColor Cyan
    Update-DatabaseCmd $prevMigration
}

function Generate-ScriptCmd {
    param(
        [string]$FromMigration,
        [string]$ToMigration
    )

    $args = @("migrations", "script")
    if ($FromMigration) { $args += $FromMigration }
    if ($ToMigration) { $args += $ToMigration }
    $args += "--output", "`"$ScriptOutput`""

    Run-EF $args
    Write-Host "SQL script generated at: $ScriptOutput" -ForegroundColor Green
}

switch ($Command.ToLower()) {
    "add"       { Add-MigrationCmd $Arguments[0] }
    "remove"    { Remove-MigrationCmd }
    "list"      { List-MigrationsCmd }
    "up"        { Update-DatabaseCmd $Arguments[0] }
    "down"      { Rollback-MigrationCmd $Arguments[0] }
    "script"    { Generate-ScriptCmd $Arguments[0] $Arguments[1] }
    "help"      { Show-Help }
    default     {
        Write-Host "Invalid command: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
}
