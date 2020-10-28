corev.db:fetchAllAsync('SELECT * FROM `identifiers`', {}, function(result)
    print('QUERY EXECUTED, NUMBER OF RESULTS : ' .. #(result or {}))
end)