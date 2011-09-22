include config.mk

install:
	@echo Installing zod executable to ${PREFIX}/bin
	@mkdir -p ${PREFIX}/bin
	@sed "s#ZODLIB_PATH#${AWKLIB}#g" < bin/zod.template > ${PREFIX}/bin/zod
	@chmod 755 ${PREFIX}/bin/zod
	@echo Installing awk lib files to ${AWKLIB}
	@mkdir -p ${AWKLIB}
	@cp lib/render.awk ${AWKLIB}/
	@cp lib/markdown.awk ${AWKLIB}/
	@echo Installation Complete
