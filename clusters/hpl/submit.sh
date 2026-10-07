#!/usr/bin/env bash
# Submit HPL on all currently idle nodes in the calling partition directory.

set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
profile=$(basename -- "$script_dir")
job_script="run${profile}.slr"

case "$profile" in
  np_guest)
    partition=notchpeak-guest
    account=owner-guest
    ;;
  np_gen)
    partition=notchpeak
    account=chpc
    ;;
  kp_guest)
    partition=kingspeak-guest
    account=owner-guest
    ;;
  kp_gen)
    partition=kingspeak
    account=chpc
    ;;
  lp_guest)
    partition=lonepeak-guest
    account=owner-guest
    ;;
  lp_gen)
    partition=lonepeak
    account=chpc
    ;;
  grn_guest)
    partition=granite-guest
    qos=granite-guest
    account=chpc
    ;;
  grn_gen)
    partition=granite
    qos=granite
    account=chpc
    ;;
  *)
    echo "Unknown HPL partition directory: $profile" >&2
    exit 2
    ;;
esac

if [ "$PWD" != "$script_dir" ]; then
  echo "Run this wrapper from $script_dir so HPL.dat is created in this directory." >&2
  exit 1
fi

for option in "$@"; do
  case "$option" in
    --reservation|--reservation=*)
      echo "Do not pass --reservation; this wrapper selects a usable reservation automatically." >&2
      exit 2
      ;;
  esac
done

nodes=$(sinfo --noheader --partition="$partition" --states=idle --format='%D' | \
  awk '{ total += $1 } END { print total + 0 }')
if [ "$nodes" -eq 0 ]; then
  echo "No idle nodes are available in the $partition partition." >&2
  exit 1
fi

slurm_args=(--partition="$partition" --account="$account")
if [ -n "${qos:-}" ]; then
  slurm_args+=(--qos="$qos")
fi

# Let Slurm validate access to every active reservation. This avoids duplicating
# its account, user, group, and scheduling eligibility rules in this script.
reservation=
while IFS= read -r candidate; do
  [ -n "$candidate" ] || continue
  if sbatch --test-only "${slurm_args[@]}" -N "$nodes" \
    --reservation="$candidate" "$@" "$job_script" >/dev/null 2>&1; then
    reservation=$candidate
    break
  fi
done < <(
  scontrol show reservation -o 2>/dev/null | awk -v partition="$partition" '
    {
      name = state = reservation_partition = ""
      for (i = 1; i <= NF; i++) {
        split($i, field, "=")
        if (field[1] == "ReservationName") name = field[2]
        else if (field[1] == "State") state = field[2]
        else if (field[1] == "PartitionName") reservation_partition = field[2]
      }
      if (name != "" && state == "ACTIVE" &&
          (reservation_partition == partition || reservation_partition == "(null)")) print name
    }'
)

submit_args=("${slurm_args[@]}" -N "$nodes")
if [ -n "$reservation" ]; then
  submit_args+=(--reservation="$reservation")
  echo "Using reservation: $reservation"
else
  echo "No usable active reservation found; submitting without one."
fi

echo "Submitting on $nodes idle $partition node(s)."
exec sbatch "${submit_args[@]}" "$@" "$job_script"
