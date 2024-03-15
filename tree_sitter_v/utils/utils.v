module utils

import os
import v.pref
import net.http

pub const ts_bin = 'tree-sitter'
pub const ts_bin_path = os.join_path(@VMODROOT, ts_bin)
const platform = pref.get_host_os()
const arch = pref.get_host_arch()
// NOTE: keeping the latest official release for now.
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

pub fn check_version() {
	// https://api.github.com/repos/tree-sitter/tree-sitter/releases/latest
}

pub fn get_ts_bin() !string {
	println('Downloading `${utils.ts_bin}`...')

	archive := utils.archives[utils.platform][utils.arch]
	http.download_file(utils.base_url + archive, archive) or {
		return error('Failed downloading archive `${archive}`. ${err}')
	}

	$if windows {
		os.execute_opt('powershell -command Expand-Archive -LiteralPath ${archive}') or {
			return error('Failed to extract archive `${archive}`. ${err}')
		}
		os.mv(archive.all_before_last('.'), utils.ts_bin_path)!
		os.rm(archive)!
	} $else {
		os.execute_opt('gzip -d ${archive}') or {
			return error('Failed to extract archive `${archive}`. ${err}')
		}
		os.mv(archive.all_before_last('.'), utils.ts_bin_path)!
		os.posix_set_permission_bit(utils.ts_bin_path, os.s_ixusr, true)
	}

	return archive
}
