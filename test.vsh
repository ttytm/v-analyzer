#!/usr/bin/env -S v

import v.pref
import os
import net.http
import time

const vexe = @VEXE
const mod_root = @VMODROOT
const ts_bin = 'tree-sitter'
const platform = pref.get_host_os()
const arch = pref.get_host_arch()
// TODO: use fixed ts version
// TODO: script in tree_sitter_v file
const base_url = 'https://github.com/tree-sitter/tree-sitter/releases/latest/download/'
const archives = {
	pref.OS.linux: {
		pref.Arch.amd64: 'tree-sitter-linux-x64.gz'
		.i386:           'tree-sitter-linux-x32.gz'
		.arm64:          'tree-sitter-linux-arm64.gz'
		.arm32:          'tree-sitter-linux-arm.gz'
	}
	.macos:        {
		pref.Arch.amd64: 'tree-sitter-macos-x64.gz'
		.arm64:          'tree-sitter-macos-arm64.gz'
	}
	.windows:      {
		pref.Arch.amd64: 'tree-sitter-windows-x64.gz'
		.arm64:          'tree-sitter-windows-arm64.gz'
	}
}

fn exec(cmd string, work_folder string, args ...string) &os.Process {
	mut p := new_process(cmd)
	p.set_work_folder(work_folder)
	p.set_args(args)
	return p
}

fn spinner(ch chan bool) {
	runes := [`-`, `\\`, `|`, `/`]
	mut pos := 0
	for {
		mut finished := false
		ch.try_pop(mut finished)
		if finished {
			print('\r')
			return
		}
		if pos == runes.len - 1 {
			pos = 0
		} else {
			pos += 1
		}
		print('\r${runes[pos]}')
		flush()
		time.sleep(100 * time.millisecond)
	}
}

fn get_ts_bin() !string {
	println('Downloading `${ts_bin}`...')

	archive := archives[platform][arch]
	dl_spinner := chan bool{cap: 1}
	spawn spinner(dl_spinner)
	http.download_file(base_url + archive, archive) or {
		return error('Failed downloading archive `${archive}`. ${err}')
	}
	dl_spinner <- true

	$if windows {
		execute_opt('powershell -command Expand-Archive -LiteralPath ${archive}') or {
			return error('Failed to extract archive `${archive}`. ${err}')
		}
		rm(archive)!
	} $else {
		execute_opt('gzip -d ${archive}') or {
			return error('Failed to extract archive `${archive}`. ${err}')
		}
	}

	mv(archive.all_before_last('.'), ts_bin)!
	posix_set_permission_bit(ts_bin, os.s_ixusr, true)

	println('Done.')
	return archive
}

// Make sure tree-sitter is executable.
ts_path := os.find_abs_path_of_executable(ts_bin) or {
	if exists(ts_bin) {
		ts_bin
	} else {
		get_ts_bin() or {
			eprintln(err)
			exit(1)
		}
		ts_bin
	}
}

mut p := exec(ts_path, '', '--version')
p.set_redirect_stdio()
p.wait()
if p.code != 0 {
	eprintln('Failed to execute ${ts_bin}.')
	exit(1)
}

println('Generating Parser...')
p = exec(ts_path, os.join_path(mod_root, 'tree_sitter_v'), 'generate')
p.wait()

println('Testing...')
p = exec(vexe, os.join_path(mod_root, 'tests'), 'run', '.')
p.wait()
