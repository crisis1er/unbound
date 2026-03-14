# Unbound Installation

## Step 1: Preparing the System
Ensure the system is updated:
```
sudo apt update
sudo apt upgrade
```

## Step 2: Installing Unbound
Install the Unbound package:
```
sudo apt install unbound
```

## Step 3: Configuring Unbound
Edit the configuration file:
```
sudo nano /etc/unbound/unbound.conf
```
In this file, customize your settings according to your needs.

## Step 4: Starting Unbound
Start the Unbound service:
```
sudo systemctl start unbound
```

## Step 5: Enabling Unbound on Boot
To ensure Unbound starts on boot, run:
```
sudo systemctl enable unbound
```

## Step 6: Verifying Installation
You can verify that Unbound is running:
```
sudo systemctl status unbound
```

## Conclusion
You have successfully installed and configured Unbound!