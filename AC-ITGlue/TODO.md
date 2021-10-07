# TODO:
```
[X]Wireless Virtual cluster (conductor) configuration. (Don't want every AP that's too many, right?)
[]Can we store running configs as documents? Can we attach them to the configuration object?
[][] Cannot create new documents via API. Maybe we can create a FlexAsset and link it to Wireless FlexAssets?
[]Add update functions to get latest data. ****
-[X] Updating Wireless FlexAsset is done, but needs adjusting. See TODO Multi-location
[]Refresh connection. Remove/reconnect ARuba AC
[]Figure out how to add multiple locations to an FlexAsset
[]See if you can utilize Topology AC API
[]Possible way to export WPA passphrase - broken: /configuration/v2/wlan/{group_name_or_guid}/{wlan_name} (NB API not enabled)
[][]Add return object to New-*
[][]Need Update function
[-]document commands
[] Update New-ACITGlueNetwork to add physical location. (Call set-*)
```