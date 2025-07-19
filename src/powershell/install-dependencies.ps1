<#
.SYNOPSIS
Sync the requirement-files into the virtual environment.

.DESCRIPTION
Install the dependencies specified in the *.txt versions of the requirement files into the venv of the project. The script needs to be exectued in the root of the project folder.

.PARAMETER ReqFilesExcluded
Comma-separated list of .in files that are not requirements files. Will be defaulted by the environment variable PY_REQ_FILE_EXCLUDED.

.PARAMETER VenvDir
Name of the virtual environment folder in the project folder root. Will be defaulted by the environment variable PY_VENV_DIR. If the environment variable is not set, the script will check for the subfolders venv and .venv.

.EXAMPLE
PS> .\install-dependencies.ps1 -ReqFileExcluded "foo.in,bar.in" -VenvDir "venv2"
#>

param(
    [string]$ReqFilesExcluded = $env:PY_REQ_FILE_EXCLUDED,
    [string]$VenvDir = $env:PY_VENV_DIR
)

if ($ReqFilesExcluded -ne $null) {
    $ExclusionList = $ReqFilesExcluded.Split(",");
}

if (-not [string]::IsNullOrWhiteSpace($VenvDir -eq $null)) {
    foreach ($dir in @('venv', '.venv', 'env', '.env')) {
        if (Test-Path -Path $dir -PathType Container) {
            $VenvDir = $dir;
            break;
        }
    }
}

# Get all .in files in the current directory, which are not excluded.
$InFiles = Get-ChildItem -Path . -Filter *.in -File | Select-Object -ExpandProperty Name | Where-Object { $_ -notin $ExclusionList }

& "$VenvDir\scripts\Activate.ps1";
# Upgrade pip-tools.
pip install -U --require-virtualenv pip-tools;
# Call pip-sync with all .txt versions of the *.in files.
pip-sync @($InFiles | ForEach-Object { $_.replace('.in', '.txt') });
deactivate;