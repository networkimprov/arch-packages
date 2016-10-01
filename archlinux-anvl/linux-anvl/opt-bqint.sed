# drivers/power/bq24190_charger.c

/const u8 battery_mask_ss/i \
	static int count;
/return IRQ_HANDLED/i \
	if (++count % 100 == 0) dev_info(bdi->dev, "int count %d\\n", count);
