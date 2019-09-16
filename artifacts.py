#! /usr/bin/env python
import os
import sys
import subprocess
import argparse
import signal

g_process = None

def LinuxDistro():
	f = open("/etc/os-release", 'r').readlines()
	for line in f:
		if "ID_LIKE" in line:
			distro=line.split("=")[1]
	return distro

def ParentSignalHandler(signal, frame):
	print "Received SIGTERM ", signal
	# Send signal to all children.
	g_process.terminate()

def RunCommand(cmd, errorMsg="", timeout = 60):
	global g_process
	print cmd
	cmdList = cmd.split()
	print cmdList
	# TODO: Once we move to python3, use proc.communicate(timeout)
	# to avoid slowing down each command by N sec or using timers.
	# Race condition between timer.is_alive() and proc.kill()
	signal.signal(signal.SIGTERM, ParentSignalHandler)
	try:
		g_process = subprocess.Popen(cmdList,
			stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	except OSError as osErr:
		print cmd
		print("OSError: %s %s %s") % (osErr.errno, osErr.strerror,
			osErr.filename)
		return False
	except subprocess.CalledProcessError as procErr:
		print cmd
		print "subprocess.CalledProcessError", procErr.output
		return False

	data, err = g_process.communicate()
	print data
	if g_process.returncode != 0:
		print "Invalid returncode ", g_process.returncode
		print err
		return False

	sleepTime = 0
	while (sleepTime < timeout) and (g_process.poll() is None):
		time.sleep(1)
		sleepTime += 1
	if (sleepTime == timeout) and (g_process.poll() is None):
		print "Killing %d due to time out" % g_process.pid
		try:
			g_process.kill()
		except:
			# Process ended naturally after proc.poll()
			# and before proc.kill().
			return True
		# Process didn't finish. Timed-out.
		return False
	return True

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

	if not RunCommand("./Debian.sh " + config,
		"Unable to build imagemagick.deb"):
		return False

	return True

def copy_deb(tag, build, config, uploadPath):
	# Copy ImageMagick.deb into artifact folder
	if config in ['ubsan', 'asan', 'san', 'debug', 'coverage']:
		pkgName = "ImageMagick-" + config
	else:
		pkgName = "ImageMagick"

	destDeb = pkgName + "_" + tag + "-" + build + ".deb"

	if not RunCommand("cp package/" + pkgName + ".deb " + destDeb,
		"Unable to copy imagemagick.deb"):
		RunCommand("ls -latr package")
		return False
	return True

def main():
	#if not RunCommand("git clean -dxxf", "Failed git clean."):
	#	return -1
	if not RunCommand("git reset --hard", "Failed git reset."):
		return -2

	# Input : archive location.
	# Input : build package config (release|debug|coverage|ubsan|asan|san)
	parser = argparse.ArgumentParser(description=\
		'Manage build artifacts.')
	parser.add_argument('--path',
		default='/pub/repository/apt/imagemagick/artifacts',
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

	distro = LinuxDistro()
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

