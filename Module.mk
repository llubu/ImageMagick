ifneq ($(MAKECMDGOALS),clean)
$(eval$(shell sh -e 3rdparty/ImageMagick/imageMagickInstall.sh $(CONFIG) $(ARCH)))
endif

clean :
	@echo 'Cleaning ImageMagick'
	$(eval$(shell sh -e 3rdparty/ImageMagick/imageMagickClean.sh $(CONFIG) $(ARCH)))
