COMPILED = www
SSH_TARGET = "someone@somewhere:/my/website/"

all:
	zod site www

sync: all
	rsync -avP -e ssh ${COMPILED} ${SSH_TARGET}
