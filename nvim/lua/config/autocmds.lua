-- `mksession` does not save tab-local variables, so the tabpage names set with
-- <leader><tab>r (see config/keymaps.lua) are lost when a session is restored.
-- Right after persistence writes a session file, inject the names into that file,
-- so loading the session (source it, or `nvim -S`) restores them with no extra hook.
local MARKER = '" tabpage names (injected by config/autocmds.lua)'

local function tab_names()
	local names = {}
	for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
		local ok, name = pcall(vim.api.nvim_tabpage_get_var, tab, "name")
		names[i] = ok and name or ""
	end
	return names
end

-- recognise the settabvar lines this file writes, so a previous injection is replaced
-- instead of being appended to (see the cleanup step in the callback)
local function is_own_settab(line)
	return line:match("^if tabpagenr%('%$'%) >= %d+ | call settabvar%(%d+, 'name', '.*'%) | endif$") ~= nil
end

vim.api.nvim_create_autocmd("User", {
	pattern = "PersistenceSavePost",
	desc = "Store tabpage names inside the session file",
	callback = function()
		local file = vim.v.this_session
		if file == "" or vim.fn.filereadable(file) == 0 then
			return
		end

		-- a session file starts with `silent tabonly`, so the tab you were on survives as tab 1
		-- and could otherwise keep a stale name: write every index, '' meaning "unnamed"
		local lines = { "", MARKER }
		for i, name in ipairs(tab_names()) do
			-- guard against a session that restores fewer tabs than were saved
			lines[#lines + 1] = ("if tabpagenr('$') >= %d | call settabvar(%d, 'name', '%s') | endif")
				:format(i, i, (name:gsub("'", "''")))
		end

		-- drop any block injected by an earlier run, so re-running on an already
		-- injected file is a no-op instead of stacking copies
		local raw = vim.fn.readfile(file)
		local content, i = {}, 1
		while i <= #raw do
			local line = raw[i]
			if line == MARKER then
				i = i + 1
			elseif line:match("^%s*$") and raw[i + 1] == MARKER then
				i = i + 2
			else
				content[#content + 1] = line
				i = i + 1
			end
			while is_own_settab(raw[i] or "") do
				i = i + 1
			end
		end

		-- insert before the SessionLoadPost autocommand so the names are already set
		-- when other plugins react to the load
		local at = #content + 1
		for n, line in ipairs(content) do
			if line:find("SessionLoadPost") then
				at = n
				break
			end
		end

		local out = {}
		vim.list_extend(out, content, 1, at - 1)
		vim.list_extend(out, lines)
		vim.list_extend(out, content, at)
		vim.fn.writefile(out, file)
	end,
})
