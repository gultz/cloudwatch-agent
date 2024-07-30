# Ensure the script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run this script as an Administrator"
    exit 1
}

# Determine the OS and Version
$OSVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version
Write-Output "Detected OS Version: $OSVersion"

function Install-CloudWatchAgent {
    $msiUrl = "https://amazoncloudwatch-agent.s3.amazonaws.com/windows/amd64/latest/amazon-cloudwatch-agent.msi"
    $msiPath = "$PSScriptRoot\amazon-cloudwatch-agent.msi"

    Write-Output "Downloading CloudWatch Agent MSI from $msiUrl"
    Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath

    # Install the CloudWatch Agent MSI
    Write-Output "Installing CloudWatch Agent"
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn" -Wait
}

# Function to configure CloudWatch Agent
function Configure-CloudWatchAgent {
    # Define the CloudWatch Agent configuration
    $config = @'
{
    "agent": {
        "metrics_collection_interval": 60
    },
    "metrics": {
        "namespace": "CWAgent",
        "append_dimensions": {
            "InstanceId": "${aws:InstanceId}"
        },
        "metrics_collected": {
            "LogicalDisk": {
                "measurement": [
                    {
                        "name": "% Free Space",
                        "rename": "DiskSpaceUtilization",
                        "unit": "percent"
                    }
                ],
                "resources": ["*"]
            },
            "Memory": {
                "measurement": [
                    {
                        "name": "% Committed Bytes In Use",
                        "rename": "MemoryUtilization",
                        "unit": "percent"
                    }
                ]
            }
        }
    }
}
'@

    $configPath = "C:\Program Files\Amazon\AmazonCloudWatchAgent\config.json"
    Write-Output "Creating CloudWatch Agent configuration file at $configPath"

    # Remove existing file if it exists
    if (Test-Path $configPath) {
        Remove-Item $configPath
    }

    # Write the configuration to the file
    [System.IO.File]::WriteAllText($configPath, $config)
}

# Function to start CloudWatch Agent
function Start-CloudWatchAgent {
    Write-Output "Starting CloudWatch Agent"
    & "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a fetch-config -m ec2 -s -c "file:C:\Program Files\Amazon\AmazonCloudWatchAgent\config.json"
    if ($?) {
        Write-Output "CloudWatch Agent started successfully."
    } else {
        Write-Error "Failed to start CloudWatch Agent."
    }
}

function Main {
    Install-CloudWatchAgent
    Configure-CloudWatchAgent
    Start-CloudWatchAgent
 
    Write-Output "CloudWatch Agent installation and configuration complete."
}

# Run the main function
Main