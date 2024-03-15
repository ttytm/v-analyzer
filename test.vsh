#!/usr/bin/env -S v

import os
import tree_sitter_v.utils

const vexe = @VEXE
const mod_root = @VMODROOT

fn exec(cmd string, work_folder string, args ...string) &os.Process {
	mut p := new_process(cmd)
	p.set_work_folder(work_folder)
	p.set_args(args)
	return p
}

// Make sure tree-sitter is executable.
// TODO:
ts_path := find_abs_path_of_executable(utils.ts_bin) or {
	if exists(utils.ts_bin) {
		utils.ts_bin
	} else {
		utils.get_ts_bin() or {
			eprintln(err)
			exit(1)
		}
		utils.ts_bin_path
	}
}

mut p := exec(ts_path, '', '--version')
p.set_redirect_stdio()
p.wait()
if p.code != 0 {
	eprintln('error: Failed to execute ${utils.ts_bin}.')
	exit(1)
}

println('Generating Parser...')
p = exec(ts_path, join_path(mod_root, 'tree_sitter_v'), 'generate')
p.wait()

println('Testing...')
p = exec(vexe, join_path(mod_root, 'tests'), 'run', '.')
p.wait()
