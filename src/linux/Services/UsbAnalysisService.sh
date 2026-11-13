#!/usr/bin/env bash
# Análise retrospectiva dos snapshots. Não implica saúde elétrica do barramento.
ons_usb_analyze() {
 local logfile="$1" initial="$2" final="$3" interval="$4" samples="$5" version="$6" destination="$7"
 local start_json end_json
 start_json="$(jq -Rsc 'split("\n")|map(select(length>0))' < "$initial")" || return 1
 end_json="$(jq -Rsc 'split("\n")|map(select(length>0))' < "$final")" || return 1
 jq -s --argjson original "$start_json" --argjson last "$end_json" \
  --arg version "$version" --arg interval "$interval" --argjson samples "$samples" '
   def dev($v): ($v | split("|")) as $s | {
     key:(($s[0] // "") + "|" + ($s[1] // "")),
     port:($s[0] // ""), vidPid:($s[1] // ""), label:($s[2] // "Sem identificação")};
   def template($d; $initial): $d + {initialPresent:$initial, finalPresent:false,
     connections:0, disconnections:0, reconnections:0, wasDisconnected:false,
     firstEvent:null,lastEvent:null};
   ([ $original[] | dev(.) ]) as $base |
   (reduce $base[] as $d ({}; .[$d.key]=template($d;true))) as $initial_state |
   (reduce (.[] | select(.event == "CONECTADO" or .event == "DESCONECTADO")) as $ev
     ($initial_state;
       (dev($ev.device)) as $d |
       .[$d.key] = (
         (.[$d.key] // template($d;false)) as $before |
         ($before + {lastEvent:$ev.time,firstEvent:($before.firstEvent // $ev.time)}) |
         if $ev.event == "CONECTADO" then
            .connections += 1 |
            .reconnections += (if $before.wasDisconnected then 1 else 0 end) |
            .wasDisconnected = false
         else
            .disconnections += 1 | .wasDisconnected = true
         end
       )
     )) as $state |
   ($last | map(dev(.) | .key)) as $end_keys |
   ($state | to_entries | map(.value | . as $v | $v + {finalPresent:(($end_keys | index($v.key)) != null)} | del(.wasDisconnected)) | sort_by(.key)) as $devices |
   {
     schemaVersion:"1.0",product:"OnSiteSuite",version:$version,
     collectionMethod:"usb_sysfs_periodic_snapshot",intervalSeconds:($interval|tonumber),samples:$samples,
     startedAt:([.[]|select(.event=="INICIO")|.time]|first),
     endedAt:([.[]|select(.event=="FIM")|.time]|last),
     initialDeviceCount:($original|length),finalDeviceCount:($last|length),
     metrics:{connections:($devices|map(.connections)|add//0),
       disconnections:($devices|map(.disconnections)|add//0),
       reconnections:($devices|map(.reconnections)|add//0),
       affectedDevices:($devices|map(select(.connections>0 or .disconnections>0))|length)},
     devices:$devices,
     limitations:["Amostragem periódica; eventos breves podem ser perdidos.",
       "Reconexão observada não identifica causa: cabo, porta, firmware, energia ou sistema.",
       "VID/PID e localização não representam necessariamente a identidade física única do dispositivo."]
   }' "$logfile" > "$destination"
}

ons_usb_check_baseline() {
 jq -e '(.product=="OnSiteSuite" and .schemaVersion=="1.0" and (.metrics|type)=="object" and (.devices|type)=="array")' "$1" >/dev/null 2>&1 || {
  printf 'Baseline USB inválido: use usb-resumo.json da v2.2.0.\n' >&2; return 2;
 }
}

ons_usb_compare() {
 local current="$1" baseline="$2" destination="$3"
 jq -e '(.product=="OnSiteSuite" and .schemaVersion=="1.0" and (.metrics|type)=="object" and (.devices|type)=="array")' "$baseline" >/dev/null 2>&1 || {
   printf 'Baseline USB inválido: use um usb-resumo.json da v2.2.0.\n' >&2; return 2;
 }
 jq -n --slurpfile current "$current" --slurpfile previous "$baseline" '
   $current[0] as $c | $previous[0] as $p |
   {schemaVersion:"1.0",product:"OnSiteSuite",comparisonType:"USB_SESSION_DELTA",
     reference:{version:$p.version,startedAt:$p.startedAt,samples:$p.samples,intervalSeconds:$p.intervalSeconds},
     current:{version:$c.version,startedAt:$c.startedAt,samples:$c.samples,intervalSeconds:$c.intervalSeconds},
     delta:{connections:($c.metrics.connections-$p.metrics.connections),
       disconnections:($c.metrics.disconnections-$p.metrics.disconnections),
       reconnections:($c.metrics.reconnections-$p.metrics.reconnections)},
     observedDeviceKeys:{previous:($p.devices|map(.key)),current:($c.devices|map(.key))},
     interpretation:"Diferença bruta de contagens. Durações, intervalos e condições diferentes impedem concluir melhora ou piora automaticamente."}' \
    > "$destination"
}
