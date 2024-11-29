events = {}

keys_pressed = {}

vim.cmd("edit")

local function split(s, delimeter)
    local res = {}
    local temp = ""

    for i in s:gmatch"." do
        if (i == delimeter) then
            table.insert(res, temp)
            temp = ""
        else
            temp = temp .. i
        end
    end

    table.insert(res, temp)
    return res
end

function Set_text(token)
    local res = split(token, "~")

    local buf = tonumber(res[1])
    local sr = tonumber(res[2])
    local sc = tonumber(res[3])
    local er = tonumber(res[4])
    local ec = tonumber(res[5])
    local data = {res[6]}

    if (er == 1) then
        local largest = er

        if sr > er then
            largest = sr
        end

        vim.api.nvim_buf_set_lines(buf, largest+1, largest+1, false, {""})
    else
        print("Setting ", data[1])
        print("Token is ", token)
        vim.api.nvim_buf_set_text(buf, sr, sc, sr+er, sc, data)
    end
end

vim.api.nvim_buf_attach(0, false, {
  on_bytes = function(bytes, buf_handle, chtick, s_row, s_col, byte_offset, old_end_row, 
      old_end_col, old_end_byte_length, new_end_row, new_end_col, new_end_len)

    table.insert(events, {
        a_buf_handle = buf_handle,
        b_start_row = s_row,
        c_start_col = s_col,
        d_end_row = new_end_row,
        e_end_column = new_end_col,
    })
    if (s_col ~= 0 or new_end_col ~= 0) then
        local byte_value = vim.api.nvim_buf_get_text(buf_handle, s_row, s_col, new_end_row+s_row, new_end_col+s_col, {}) 
        if (#byte_value > 1) then
            table.insert(keys_pressed, "na")
        else
            table.insert(keys_pressed, byte_value[1])
        end

        if Client and Is_connected then
            Write_shit_to_server(keys_pressed[#keys_pressed])
        end
    end

  end,
})

