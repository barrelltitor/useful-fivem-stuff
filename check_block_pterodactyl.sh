# Needs Locations, Nodes and Allocations on read everything else can be denied
APPLICATION_API_KEY=
BASE_API_URL=https://panel.yourURL.com/api
call_ptero(){
    local API_PATH API_METHOD API_DATA;
    API_PATH="$2";
    API_METHOD="$1";
    API_DATA="$3";
    if [[ $API_METHOD == "POST_BODY" ]] ; then
      curl -s "$BASE_API_URL/$API_PATH" \
      -H 'Accept: application/json' \
      -H "Authorization: Bearer ${APPLICATION_API_KEY}" \
      -X "POST" \
      -d "$API_DATA";
      return 0
    fi; 
    if [[ $API_METHOD == "GET" ]] || [[ $API_METHOD == "DELETE" ]]; then
    curl -s "$BASE_API_URL/$API_PATH" \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer ${APPLICATION_API_KEY}" \
      -X "$API_METHOD" ;
    else
      curl -s "$BASE_API_URL/$API_PATH" \
      -H 'Accept: application/json' \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer ${APPLICATION_API_KEY}" \
      -X "$API_METHOD" \
      -d "$API_DATA";
    fi;  
}

check_block(){
local ip status name
ip=$1
name=$2
status=$(curl -s -o /dev/null -w "%{http_code}" "https://runtime.fivem.net/blacklist/$ip")
if [ "$status" != "404" ]; then
    echo "$name - $ip" - blocked
fi

}


resp="$(call_ptero GET 'application/locations?include=nodes&per_page=1000')"

# Here set the names of your locations, the xample will likely not work for you 
declare -A locmap=(
  ["Virginia, USA"]="va"
  ["London, UK"]="lon"
)

# long is the longname
for long in "${!locmap[@]}"; do
  code="${locmap[$long]}"
  ids=$(jq -r --arg l "$long" \
    '.data[] | select(.attributes.short==$l) | .attributes.relationships.nodes.data[].attributes.id' \
    <<<"$resp")
  eval "$code=($ids)"
done


for long in "${!locmap[@]}"; do
  code="${locmap[$long]}"
  declare -n arr="$code"
  echo "Location: $long (array: $code)"
  for node in "${arr[@]}"; do
    allocs="$(call_ptero GET "application/nodes/$node?include=allocations&per_page=1000")"
    node_name=$(echo "$allocs"| jq '.attributes.name' -r)
    ips=$(jq -r '.attributes.relationships.allocations.data[].attributes.ip' <<<"$allocs" | sort -u)
    echo "$ips" > debug
    for ip in $ips; do
      check_block "$ip" "$node_name"
    done
  done
done


