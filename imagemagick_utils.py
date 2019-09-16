#!/usr/bin/python
import os
import sys
import time
import subprocess
import signal
import stat
import multiprocessing
# TODO: Remove this once windows jenkins has enough space
if not os.name == 'nt':
	import paramiko
	import scp

g_process = None

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

def ScpFile(client, path, directory = False):
	""" Scps file from given path to dst dir
	Args:
		client (scp): The scp client handle
		path (str): Src path for file
		directory (bool): if true, transfer directories
	Return:
		bool: True if scp succeeds. Else False.
	"""
	result = True
	print 'Scp file from ' + path
	try:
		client.get(path, recursive=directory)
	except:
		print 'Unable to scp file'
		result = False
	return result

def CpuCount():
	return multiprocessing.cpu_count()

def LinuxDistro():
	f = open("/etc/os-release", 'r').readlines()
	for line in f:
		if "ID_LIKE" in line:
			distro=line.split("=")[1]
	return distro

