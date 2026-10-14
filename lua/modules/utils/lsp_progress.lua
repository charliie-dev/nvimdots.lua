-- LSP progress for the statusline, tracked per client and token so that one task ending does not
-- clear another that is still running.
local M = {}

local spinners = { "", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥", "", "" }

---@type table<string, { client_id: integer, title: string?, percentage: integer, text: string, seq: integer }>
local tasks = {}
local seq = 0

---Record an LspProgress event
---@param data table? `args.data` of the LspProgress autocmd
function M.update(data)
	local params = data and data.params
	local value = params and params.value
	if not (data and data.client_id and value) then
		return
	end
	local key = data.client_id .. ":" .. tostring(params.token)
	if value.kind == "end" then
		tasks[key] = nil
		return
	end
	-- `report` messages usually omit the title and may omit the percentage; keep the task's own.
	local previous = tasks[key] or {}
	local title = value.title or previous.title
	local pct = value.percentage or previous.percentage or 0
	local count = value.message and value.message:match("^%d+/%d+")
	seq = seq + 1
	tasks[key] = {
		client_id = data.client_id,
		title = title,
		percentage = pct,
		seq = seq,
		-- "<spinner> XX% <title> <done/total>"; `%%` escapes the statusline
		text = spinners[1 + (pct - pct % 10) / 10]
			.. " "
			.. pct
			.. "%% "
			.. (title or "")
			.. (count and " " .. count or ""),
	}
end

---Progress of the most recently updated running task, or "" when none is running
---@return string
function M.text()
	local latest
	for key, task in pairs(tasks) do
		local client = vim.lsp.get_client_by_id(task.client_id)
		if not client or client:is_stopped() then
			tasks[key] = nil -- the client exited without ending the task
		elseif not latest or task.seq > latest.seq then
			latest = task
		end
	end
	return latest and latest.text or ""
end

return M
