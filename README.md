# ACITGlue
Links data from Aruba Central to IT Glue to keep things synchronized.
This includes sites, networks, aps, and switches.

## Getting started
This will connect to both ITGlue and Aruba Central
```
New-ACITglueConnection
```
## Get OrgId for organization
```
Get-ACITGlueOrgId
```
# Run the below command to sync everything that it can.
```
New-ACITGlueSync -OrgId 111111
New-ACITGlueSync -OrgId (Get-ACITGlueOrgId)
```

# Syncs/Updates network (SSID) data with ITGlue.
(Does not add any new networks)
```
Set-ACITGlueNetwork
```

# Syncs switches with ITGlue.
```
New-ACITGlueSwitch
```

# Syncs Aruba Central Sites to locations within ITGlue.
```
New-ACITGlueSites
```

# Syncs Aruba Central Subscriptions to Licensing FlexAsset within ITGlue
```
New-ACITGlueSubscription
```