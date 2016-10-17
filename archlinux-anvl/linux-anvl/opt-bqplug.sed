# drivers/power/bq24190_charger.c

/if ((bdi->ss_reg & battery_mask_ss) != (ss_reg & battery_mask_ss)) {/i \
		if ((bdi->ss_reg & BQ24190_REG_SS_PG_STAT_MASK) !=\
				(ss_reg & BQ24190_REG_SS_PG_STAT_MASK))\
			dev_info(bdi->dev, "usb %s\\n", (ss_reg & BQ24190_REG_SS_PG_STAT_MASK) ? "on" : "off");\

