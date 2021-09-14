# ACITGlue
Links data from Aruba Central to IT Glue to keep things synchronized.
This includes sites, networks, aps, and switches.

## Getting started
This will connect to both ITGlue and Aruba Central
```
New-ACITglueConnection
```

# Run the below command to sync everything that it can.
```
New-ACITGlueSync
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