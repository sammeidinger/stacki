# @copyright@
# Copyright (c) 2006 - 2018 Teradata
# All rights reserved. Stacki(r) v5.x stacki.com
# https://github.com/Teradata/stacki/blob/master/LICENSE.txt
# @copyright@
#
# @rocks@
# Copyright (c) 2000 - 2010 The Regents of the University of California
# All rights reserved. Rocks(r) v5.4 www.rocksclusters.org
# https://github.com/Teradata/stacki/blob/master/LICENSE-ROCKS.txt
# @rocks@

from stack.argument_processors.firmware import FirmwareArgProcessor
import stack.commands

class command(stack.commands.list.command, FirmwareArgProcessor):
	pass

class Command(command):
	"""
	Lists all firmware images tracked by stacki.

	<param type='bool' name='expanded'>
	Set this to list more detailed firmware image information
	</param>

	<example cmd="stack list firmware">
	Lists all firmware files tracked in the stacki database.
	</example>
	"""

	def run(self, params, args):
		expanded, = self.fillParams(
			names = [("expanded", False)],
			params = params,
		)
		expanded = self.str2bool(expanded)

		header = []
		values = []
		for provides, results in self.runPlugins(args = expanded):
			header.extend(results["keys"])
			values.extend(results["values"])

		self.beginOutput()
		for owner, vals in values:
			self.addOutput(owner = owner, vals = vals)
		self.endOutput(header = header)
