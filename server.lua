local Framework = nil

-- Inicialización del framework
Citizen.CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Framework = 'ESX'
        ESX = exports["es_extended"]:getSharedObject()
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'QBCore'
        QBCore = exports['qb-core']:GetCoreObject()
    else
        print('No se detectó ESX ni QBCore. El script puede no funcionar correctamente.')
    end
end)

-- Evento para sincronizar las modificaciones de handling entre clientes
RegisterNetEvent('syncVehicleHandling')
AddEventHandler('syncVehicleHandling', function(netId, handling)
    local source = source
    local xPlayer

    if Framework == 'ESX' then
        xPlayer = ESX.GetPlayerFromId(source)
    elseif Framework == 'QBCore' then
        xPlayer = QBCore.Functions.GetPlayer(source)
    end

    if xPlayer and Config.AllowedJobs[xPlayer.job.name] then
        TriggerClientEvent('syncVehicleHandling', -1, netId, handling)
        -- Aquí puedes agregar lógica adicional, como guardar las modificaciones en la base de datos
    else
        print('Jugador no autorizado intentó modificar el handling de un vehículo:', source)
    end
end)

-- Función para cargar los datos de los coches (a implementar)
function LoadCarData()
    -- Aquí se cargarían los datos de los coches desde la base de datos
    -- y se enviarían al cliente
    return {
        { id = 1, name = 'Adder', brand = 'Truffade' },
        { id = 2, name = 'Zentorno', brand = 'Pegassi' },
        { id = 3, name = 'T20', brand = 'Progen' }
    }
end

-- Evento para cuando un jugador se conecta
if Framework == 'ESX' then
    ESX.RegisterServerCallback('getCarData', function(source, cb)
        cb(LoadCarData())
    end)
elseif Framework == 'QBCore' then
    QBCore.Functions.CreateCallback('getCarData', function(source, cb)
        cb(LoadCarData())
    end)
end