#! /bin/bash

# check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Determine the OS and Version
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os=$ID
    version=$VERSION_ID
else
    echo "Unsupported OS"
    exit 1
fi

# Update package manager and install CloudWatch Agent
install_cloudwatch_agent() {
    if [[ $os == "amzn" ]]; then
        yum install -y amazon-cloudwatch-agent
    elif [[ $os == "ubuntu" ]]; then
        wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
        dpkg -i -E ./amazon-cloudwatch-agent.deb
    elif [[ $os == "rhel" ]]; then
        yum install wget -y
        wget https://amazoncloudwatch-agent.s3.amazonaws.com/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
        sudo rpm -U ./amazon-cloudwatch-agent.rpm
    else
        echo "Unsupported OS version"
        exit 1
    fi
}

# Configure CloudWatch Agent for Amazon Linux
configure_cloudwatch_agent() {
    cat <<EOL > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
    },
    "metrics": {
        "namespace": "CWAgent",
        "append_dimensions": {
            "InstanceId": "\${aws:InstanceId}"
        },
        "aggregation_dimensions": [
            ["InstanceId","device","fstype","path"]
        ],
        "metrics_collected": {
            "mem": {
                "measurement": [
                    {"name": "mem_used_percent", "rename": "MemoryUtilization","unit": "Percent"}
                ]
            },
            "disk": {
                "measurement": [
              
                    {   
                        "name": "disk_used_percent", "rename": "DiskSpaceUtilization", "unit": "Percent"
                    }
                ],
                "ignore_file_system_types": ["devtmpfs","tmpfs","vfat","squashfs"]
            }
        }
    }
}
EOL
}



# Start CloudWatch Agent
start_cloudwatch_agent() {
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
}

# MAIN
install_cloudwatch_agent
configure_cloudwatch_agent
start_cloudwatch_agent

echo "CloudWatch Agent installation and configuration complete."