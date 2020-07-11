# @copyright@
# Copyright (c) 2006 - 2019 Teradata
# All rights reserved. Stacki(r) v5.x stacki.com
# https://github.com/Teradata/stacki/blob/master/LICENSE.txt
# @copyright@

import os
import stack.commands
from .imp_base import PXEImplementation

class Implementation(PXEImplementation):

	def run(self, args):
		h = args[0]
		i = args[1]

		host      = h['host']
		kernel    = h['kernel']
		ramdisk   = h['ramdisk']
		args      = h['args']
		attrs     = h['attrs']
		boottype  = h['type']

		interface = i['interface']
		ip        = i['ip']
		mac       = i['mac']
		mask      = i['mask']
		gateway   = i['gateway']
		
		self.owner.addOutput(host, self.get_sux_header(os.path.join(os.path.sep,
									    'tftpboot',
									    'pxelinux',
									    'pxelinux.cfg',
									    self.get_tftpboot_filename(mac))))
		self.owner.addOutput(host, 'default stack')
		self.owner.addOutput(host, 'prompt 0')
		self.owner.addOutput(host, 'label stack')

		if kernel:
			if kernel[0:7] == 'vmlinuz':
				self.owner.addOutput(host, '\tkernel %s' % (kernel))
			else:
				self.owner.addOutput(host, '\t%s' % (kernel))
		if ramdisk and len(ramdisk) > 0:
			if len(args) > 0:
				args += ' initrd=%s' % ramdisk
			else:
				args = 'initrd=%s' % ramdisk

		if args and len(args) > 0:
			self.owner.addOutput(host, '\tappend %s' % args)
		if boottype == "install":
			self.owner.addOutput(host, '\tipappend 2')

		self.owner.addOutput(host, self.get_sux_trailer())
