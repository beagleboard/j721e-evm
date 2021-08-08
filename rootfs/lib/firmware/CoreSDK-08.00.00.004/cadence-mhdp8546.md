https://git.ti.com/gitweb?p=processor-firmware/ti-linux-firmware.git;a=commit;h=7bad9a69a343e01056ece5ce6da4d4060c42f6bc

linux-firmware: update firmware for mhdp8546

This patch updates mhdp8546 firmware from v1.2.15 to v1.2.17.

Improvements in handling responses on AUX channel and reading EDID
blocks.

While at it, drop the pointless executable flag from the file.

Signed-off-by: Tomi Valkeinen <tomi.valkeinen@ti.com>
Acked-by: Dan Murphy <dmurphy@ti.com>
