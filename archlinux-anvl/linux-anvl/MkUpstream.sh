#!/bin/bash

set -e

Fil=upstream-4.7.patch

Src=(
  compare/anvl-v4.7...anvl-v4.7-defconfig # local
  compare/anvl-v4.7...anvl-v4.7-leds-dt
  compare/anvl-v4.7...anvl-v4.7-lb-mwifiex
  commit/54f56c3a # twl4030.dtsi
  compare/anvl-v4.7...anvl-v4.7-phy-twl4030
  compare/anvl-v4.7...anvl-v4.7-lb-bq24190
  commit/298b7a5a # bq27xxx
  compare/09615628...anvl-v4.7-bq27xxx
  compare/anvl-v4.7...anvl-v4.7-spi-validation # local
)

cd $(dirname $0)

curl -sLO https://github.com/networkimprov/linux/raw/anvl-v4.7/arch/arm/boot/dts/omap3-anvl.dts

echo "omap3-anvl.dts $(wc -l < omap3-anvl.dts) lines"

cat /dev/null > "$Fil"
for f in ${Src[@]}; do
  curl -sL https://github.com/networkimprov/linux/${f}.patch >> "$Fil"
done

echo "$Fil $(wc -l < "$Fil") lines"

