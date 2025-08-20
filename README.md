# check_block_pterodactyl.sh
Checks each **node allocation IP** from your Pterodactyl panel against FiveM's runtime blacklist to see if any of them are banned 

You will need to modify the map of the long location names to "code readable" array names, as in the example

```
# Here set the names of your locations, the xample will likely not work for you 
declare -A locmap=(
  ["Virginia, USA"]="va"
  ["London, UK"]="lon"
)
```

This is MIT or w/e you want, sell it, use it, abuse it, give it to your mom, gift it to your uncle, use it to grow your hair back or make your wife forgive you. 

If you want a Pterodactyl dev/sysadmin/programmer contact me
