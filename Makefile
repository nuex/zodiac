include config.mk

all:
	@echo Compiling zod executable
	@sed "s#ZODLIB_PATH#${AWKLIB}#g" < bin/zod.template > bin/zod
	@echo Compiled

install: all
	@echo Installing zod executable to ${PREFIX}/bin
	@mkdir -p ${PREFIX}/bin
	@chmod 755 ${PREFIX}/bin/zod
	@echo Installing awk lib files to ${AWKLIB}
	@mkdir -p ${AWKLIB}
	@cp lib/render.awk ${AWKLIB}/
	@cp lib/markdown.awk ${AWKLIB}/
	@echo Installation Complete

uninstall:
	@echo Uninstalling zod executable
	@rm ${PREFIX}/bin/zod
	@echo Uninstalling awk lib files
	@rm -rf ${AWKLIB}
	@echo Uninstallation Complete
