# cloudwatch-agent
install and configure the CloudWatch Agent with a single script.

## Compatibility

The script supports these Linux distributions:

|                    | Support |
| ------------------ | ------- |
| Amaozon Linux 2023 | ✅      |
| Amazon Linux 2     | ✅      |
| Ununtu >= 20.04    | ✅      |
| Rhel >=8           | ✅      |
| centos >=8         | ✅      |
| rocky >=8          | ✅      |
| Windows>= 2016     | ✅      |


## Features

 collect memory utilization and disk utilization through custom metrics on windows, linux 

## Usage

### linux

```bash
wget https://jinseokk-bucket.s3.ap-northeast-2.amazonaws.com/cloudwatch_linux.sh
sudo -s
./cloudwatch_linux.sh
```

### window
```bash
Invoke-WebRequest -Uri "https://jinseokk-bucket.s3.ap-northeast-2.amazonaws.com/cloudwatch_window.ps1" -OutFile ".\cloudwatch_window.ps1"
Set-ExecutionPolicy Unrestricted -Scope Process -Force
.\cloudwatch_window.ps1
```

### window-2016
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://jinseokk-bucket.s3.ap-northeast-2.amazonaws.com/cloudwatch_window.ps1" -OutFile ".\cloudwatch_window.ps1"
```

## status check

### linux
```
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```

### window
```
& $Env:ProgramFiles\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1 -m ec2 -a status
```

## self run

### linux
```
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
```

### window
```
& "C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1" -a fetch-config -m ec2 -s -c "file:C:\Program Files\Amazon\AmazonCloudWatchAgent\config.json”
```

