include config.mk

all:
	@echo Compiling zod executable
	@sed "s#ZODLIB_PATH#${AWKLIB}#g" < bin/zod.template > bin/zod
	@chmod 755 bin/zod
	@echo Compiled

install: all
	@echo Installing zod executables to ${PREFIX}/bin
	@mkdir -p ${PREFIX}/bin
	@cp bin/zod ${PREFIX}/bin
	@cp bin/zod-render ${PREFIX}/bin
	@cp bin/zod-copy ${PREFIX}/bin
	@cp bin/zod-internal ${PREFIX}/bin
	@echo Installing awk lib files to ${AWKLIB}
	@mkdir -p ${AWKLIB}
	@cp lib/render.awk ${AWKLIB}
	@cp lib/markdown.awk ${AWKLIB}
	@cp lib/config.awk ${AWKLIB}
	@cp lib/find_cmd.awk ${AWKLIB}
	@echo Installation Complete

uninstall:
	@echo Uninstalling zod executables
	@rm ${PREFIX}/bin/zod
	@rm ${PREFIX}/bin/zod-render
	@rm ${PREFIX}/bin/zod-copy
	@rm ${PREFIX}/bin/zod-internal
	@echo Uninstalling awk lib files
	@rm -rf ${AWKLIB}
	@echo Uninstallation Complete
