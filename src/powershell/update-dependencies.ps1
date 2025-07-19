<#
.SYNOPSIS
Update the requirement-files and sync them into the virtual environment.

.DESCRIPTION
Update the dependencies specified in the *.in requirement files to their latest versions and install them into the venv of the project. The script needs to be exectued in the root of the project folder.

.PARAMETER ReqFilesExcluded
Comma-separated list of .in files that are not requirements files. Will be defaulted by the environment variable PY_REQ_FILE_EXCLUDED.

.PARAMETER VenvDir
Name of the virtual environment folder in the project folder root. Will be defaulted by the environment variable PY_VENV_DIR. If the environment variable is not set, the script will check for the subfolders venv and .venv.

.EXAMPLE
PS> .\update-dependencies.ps1 -ReqFiles "requirements.in,dev-requirement.in" -VenvDir "venv2"
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
# Upgrade pip.
python -m pip install --upgrade pip;
# Upgrade pip-tools.
pip install -U --require-virtualenv pip-tools;
# Call pip-compile -U for all *.in files.
$InFiles | ForEach-Object { pip-compile -U $_ };
# Call pip-sync with all .txt versions of the *.in files.
pip-sync @($InFiles | ForEach-Object { $_.replace('.in', '.txt') });
deactivate