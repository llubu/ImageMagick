#! /usr/bin/env python
import os
import sys
import subprocess
import argparse
import pdfkit
import skillet_utils as skutils

def getCmdOutput(cmd):
	try:
		args = cmd.split()
		return subprocess.check_output(args).strip()
	except:
		return ""

def make_deb(tag, build, config):
	# Update the control file.
	debVersion = "Version: "
	if tag is None or len(tag) < 2:
		version = "7.0.8.63"
	else:
		if tag[0] == 'v':
			version = tag[1:]
		elif tag[0].isdigit():
			version = tag;
		else:
			version = "7.0.8.63"
	debVersion += version + "-" + build + "\n"

	try:
		control = "./DEBIAN/control"
		f = open(control, "a")
		f.write(debVersion)
		f.close()
	except:
		print "Unable to update version in DEBIAN/control.", \
			sys.exc_info()[0]
		return False

	if not skutils.RunCommand("./Debian.sh " + config,
		"Unable to build imagemagick.deb"):
		return False

	return True

def copy_deb(tag, build, config, uploadPath):
	# Copy skillet.deb into artifact folder
	if config in ['ubsan', 'asan', 'san', 'debug', 'coverage']:
		pkgName = "ImageMagick-" + config
	else:
		pkgName = "ImageMagick"

	destDeb = pkgName + "_" + tag + "-" + build + ".deb"

	if not skutils.RunCommand("cp package/" + pkgName + ".deb " + destDeb,
		"Unable to copy imagemagick.deb"):
		skutils.RunCommand("ls -latr package")
		return False
	if not skutils.RunCommand("scp " + destDeb + " adabral@carbon:"
		+ uploadPath, "Unable to scp artifact into archive path"):
		return -2
	return True

def main():
	#if not skutils.RunCommand("git clean -dxxf", "Failed git clean."):
	#	return -1
	if not skutils.RunCommand("git reset --hard", "Failed git reset."):
		return -2

	# Input : archive location.
	# Input : build package config (release|debug|coverage|ubsan|asan|san)
	parser = argparse.ArgumentParser(description=\
		'Manage build artifacts.')
	parser.add_argument('--path',
		default='/pub/repository/apt/skillet/artifacts',
		help='Path to store build artifacts')
	parser.add_argument('--config',
		default='release',
		help='[release/debug/coverage | ubsan/asan/san]')
	args = parser.parse_args()

	# Add information about build in README.txt
	try:
		build = os.environ["BUILD_NUMBER"]
	except:
		build = "0"

	sha = getCmdOutput("git describe --abbrev=0")
	branch = getCmdOutput("git symbolic-ref --short HEAD")
	if branch is None or branch == sha:
		try:
			branch = os.environ["GIT_BRANCH"]
		except:
			branch = None
	slash = branch.find('/')
	if slash != -1:
		branch = branch[(slash + 1):]
	tag = getCmdOutput("git describe --abbrev=0 --exact-match")
	if tag is None or tag == "":
		tag = branch
	slash = tag.find('/')
	if slash != -1:
		tag = tag[(slash + 1):]
	version = tag
	if build != 0:
		version += "-" + build
	artifact = "imagemagick_" + version

	distro = skutils.LinuxDistro()
	if ("debian" in distro):
		if not make_deb(tag, build, args.config):
			return -2
		if not copy_deb(tag, build, args.config, args.path):
			return -3


	elif ("rhel fedora" in distro):
		return -5

	return 0

if __name__ == '__main__':
	sys.exit(main())

