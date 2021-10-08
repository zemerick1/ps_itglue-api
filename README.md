# ACITGlue
Links data from Aruba Central to IT Glue to keep things synchronized.
This includes sites, networks, aps, and switches.

## Getting started

### Installation
Install and Import the module

```
Install-Module AC-ITGlue
Import-Module AC-ITGlue
```

### Create Aruba Central connection and store IT-Glue API Key
This will connect to both ITGlue and Aruba Central
```
New-ACITglueConnection
```

# Run the below command to sync everything that it can.
```
New-ACITGlueSync -OrgId 111111
New-ACITGlueSync -OrgId (Get-ACITGlueOrgId)
```
This is equivalent to running the below commands:

```
New-ACITGlueSite -OrgId 111111
New-ACITGlueNetwork -OrgId 111111
New-ACITGlueSwitch -OrgId 111111
New-ACITGlueAP -OrgId 111111
Set-ACITGlueNetwork -OrgId 111111
New-ACITGlueSubscription -OrgId 111111
```

# Syncs switches with ITGlue.
```
New-ACITGlueSwitch -OrgId 111111
```

# Syncs Aruba Central Network (SSID) data with ITGlue.
```
New-ACITGlueNetwork -OrgId 111111
```

# Updates network (SSID) data with ITGlue.
(Does not add any new networks)
```
Set-ACITGlueNetwork -OrgId 111111
```

# Syncs Aruba Central Sites to locations within ITGlue.
```
New-ACITGlueSite -OrgId 111111
```

# Syncs Aruba Central Subscriptions to Licensing FlexAsset within ITGlue
```
New-ACITGlueSubscription -OrgId 111111
```

## Get OrgId for organization
```
Get-ACITGlueOrgId 
```