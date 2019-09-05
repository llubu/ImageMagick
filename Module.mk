ifneq ($(MAKECMDGOALS),clean)
$(eval$(shell sh -e 3rdparty/ImageMagick/imageMagickInstall.sh))
endif

clean :
	@echo 'Cleaning ImageMagick'
	$(eval$(shell sh -e 3rdparty/ImageMagick/imageMagickClean.sh))
