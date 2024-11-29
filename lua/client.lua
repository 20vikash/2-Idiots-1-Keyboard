local uv = vim.loop

Server_stuff = {}
Client = uv.new_tcp()
Is_connected = false


local function check_et(a, b)
  if (#a ~= #b) then
    return false
  end

  for k, _ in ipairs(a) do
    if (a[k] ~= b[k]) then
      return false
    end
  end

  return true
end

function Write_shit_to_server(shit)
    local temp = events[#events]
    temp["value"] = shit
    local res_string = ""
    local seq_temp = {}

    for k, _ in pairs(temp) do
        table.insert(seq_temp, k)
    end

    table.sort(seq_temp)

    for _, v in ipairs(seq_temp) do
        if #res_string > 0 then
            res_string = res_string .. "~" .. tostring(temp[v])
            if (tostring(temp[v]) == "na") then
                table.insert(Server_stuff, "na")
            end
        else
            res_string = tostring(temp[v])
        end
    end
    print(res_string)

    Client:write(res_string)
end

Client:connect("127.0.0.1", 8081, function(err)
    assert(not err, err)
    Is_connected = true

    Client:read_start(function(err2, data)
        assert(not err2, err2)

        if data then
            if (string.sub(data, -2) ~= 'na') then
                table.insert(Server_stuff, string.sub(data, -1))
            else
                table.insert(Server_stuff, string.sub(data, -2))
            end

            vim.schedule(function()
                if (not check_et(Server_stuff, keys_pressed)) then
                    Set_text(data)
                    if (string.sub(data, -2) == "na") then
                        table.insert(keys_pressed, "na")
                    end
                end
            end)

        else
            print("Connection closed by the server")
            Client:close()
        end
    end)

end)

