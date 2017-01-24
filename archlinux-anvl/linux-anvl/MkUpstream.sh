#!/bin/bash

set -e

Fil=upstream-4.9.patch

SrcUpstream=(
  tmlind/linux-omap,d97556c8 # ARM: dts: Fix omap3 off mode pull defines
  stable/linux-stable,950b6c2d # power: supply: bq27xxx_battery: don't update poll_interval param if same
  stable/linux-stable,9d052aa0 # phy: phy-twl4030-usb: emit VBUS status events to userspace
  stable/linux-stable,35c7d301 # leds: pca963x: workaround group blink scaling issue
  stable/linux-stable,a8c170b0 # leds: pca963x: enable low-power state
  sre/linux-power-supply,767eee36 # power: supply: bq24190_charger: Fix irq trigger to IRQF_TRIGGER_FALLING
  sre/linux-power-supply,e05ad7e0 # power: supply: bq24190_charger: Call set_mode_host() on pm_resume()
  sre/linux-power-supply,d62acc5e # power: supply: bq24190_charger: Install irq_handler_thread() at end of probe()
  sre/linux-power-supply,2d9fee6a # power: supply: bq24190_charger: Call power_supply_changed() for relevant component
  sre/linux-power-supply,68abfb80 # power: supply: bq24190_charger: Don't read fault register outside irq_handle_thread()
  sre/linux-power-supply,ba52e757 # power: supply: bq24190_charger: Handle fault before status on interrupt
  sre/linux-power-supply,cb190af2 # power: supply: bq24190_charger: Adjust formatting
)

SrcGithub=(
  compare/anvl-v4.7...anvl-v4.7-omap2config # local
#  commit/08652bc3 # ASoC: omap-mcbsp: Add PM QoS support for McBSP to prevent glitches
  compare/anvl-v4.7...anvl-v4.7-pca963x-anvl # local
  commit/8a3d476c # mwifiex: fix p2p device doesn't find in scan problem
#  compare/anvl-v4.7...anvl-v4.7-phy-twl4030
#  compare/09615628...anvl-v4.7-bq27xxx # local
#  compare/anvl-v4.7...anvl-v4.7-bq24190-int
  commit/57ea80ad # mmc: pwrseq: initial pwrseq support for Marvell SD8787
#  compare/anvl-v4.9...anvl-v4.9-bq27425-nvram-v7
  compare/anvl-v4.7...anvl-v4.7-spi-validation # local
  compare/anvl-v4.9...anvl-v4.9-dts-pullup # local
)

cd $(dirname $0)

curl -sLO https://github.com/networkimprov/linux/raw/anvl-v4.9/arch/arm/boot/dts/omap3-anvl.dts

echo "omap3-anvl.dts $(wc -l < omap3-anvl.dts) lines"

cat /dev/null > "$Fil"
for f in ${SrcUpstream[@]}; do
  curl -sL https://git.kernel.org/cgit/linux/kernel/git/${f%%,*}.git/patch/\?id=${f##*,} >> "$Fil"
done
for f in ${SrcGithub[@]}; do
  curl -sL https://github.com/networkimprov/linux/${f}.patch >> "$Fil"
  printf -- '--\ngithub\n\n' >> "$Fil"
done
#sed -i 's|drivers/power/|drivers/power/supply/|g' "$Fil"

echo "$Fil $(grep ^Subject: "$Fil" | wc -l) patches"

