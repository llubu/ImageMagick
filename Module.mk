ifneq ($(MAKECMDGOALS),clean)
$(eval$(shell sh -e scripts/imageMagickInstall.sh))
endif

clean :
	@echo 'Cleaning ImageMagick'
	$(eval$(shell sh -e scripts/imageMagickClean.sh))

