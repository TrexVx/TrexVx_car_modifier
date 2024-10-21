local PlayerData = {}
local isMenuOpen = false
local currentVehicle = nil

-- Inicialización del framework
Citizen.CreateThread(function()
    while Config.Framework == nil do
        Citizen.Wait(100)
    end

    if Config.Framework == 'ESX' then
        ESX = exports["es_extended"]:getSharedObject()
        PlayerData = ESX.GetPlayerData()
    elseif Config.Framework == 'QBCore' then
        QBCore = exports['qb-core']:GetCoreObject()
        PlayerData = QBCore.Functions.GetPlayerData()
    end
end)

-- Función para verificar si el jugador tiene el trabajo permitido
local function HasAllowedJob()
    if Config.Framework == 'ESX' then
        return Config.AllowedJobs[PlayerData.job.name]
    elseif Config.Framework == 'QBCore' then
        return Config.AllowedJobs[PlayerData.job.name]
    end
    return false
end

-- Función para abrir la interfaz NUI
function OpenHandlingMenu()
    if not isMenuOpen and HasAllowedJob() then
        currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if currentVehicle ~= 0 then
            isMenuOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = "openMenu",
                handling = GetVehicleHandling(currentVehicle)
            })
            print("Abriendo el menú de handling")
        else
            print("No estás en un vehículo")
        end
    else
        print("No tienes permiso para abrir este menú o ya está abierto")
    end
end

-- Función para cerrar la interfaz NUI
function CloseHandlingMenu()
    if isMenuOpen then
        isMenuOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "closeMenu"
        })
        print("Cerrando el menú de handling")
    end
end

-- Comando para abrir el menú de handling
RegisterCommand("handlingmenu", function()
    OpenHandlingMenu()
end, false)

-- Tecla para abrir/cerrar el menú (F7 en este ejemplo)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustReleased(0, 168) then -- 168 es el código para F7
            if isMenuOpen then
                CloseHandlingMenu()
            else
                OpenHandlingMenu()
            end
        end
    end
end)

-- Manejar el cierre del menú desde la interfaz NUI
RegisterNUICallback('closeMenu', function(data, cb)
    CloseHandlingMenu()
    cb('ok')
end)

-- Manejar las modificaciones de handling recibidas desde la interfaz NUI
RegisterNUICallback('modifyHandling', function(data, cb)
    if currentVehicle ~= 0 and HasAllowedJob() then
        local handling = data.handling
        for k, v in pairs(handling) do
            SetVehicleHandlingFloat(currentVehicle, 'CHandlingData', k, v)
        end
        
        -- Sincronizar las modificaciones con el servidor
        TriggerServerEvent('syncVehicleHandling', VehToNet(currentVehicle), handling)
        
        cb({status = 'ok'})
    else
        cb({status = 'error', error = 'No estás en un vehículo o no tienes permiso'})
    end
end)

-- Función para obtener el handling actual del vehículo
function GetVehicleHandling(vehicle)
    local handling = {}
    for _, property in ipairs(Config.HandlingProperties) do
        handling[property] = GetVehicleHandlingFloat(vehicle, 'CHandlingData', property)
    end
    return handling
end

-- Evento para sincronizar las modificaciones de handling de otros jugadores
RegisterNetEvent('syncVehicleHandling')
AddEventHandler('syncVehicleHandling', function(netId, handling)
    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        for k, v in pairs(handling) do
            SetVehicleHandlingFloat(vehicle, 'CHandlingData', k, v)
        end
    end
end)

-- Actualizar los datos del jugador cuando cambia de trabajo
if Config.Framework == 'ESX' then
    RegisterNetEvent('esx:setJob')
    AddEventHandler('esx:setJob', function(job)
        PlayerData.job = job
    end)
elseif Config.Framework == 'QBCore' then
    RegisterNetEvent('QBCore:Client:OnJobUpdate')
    AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
        PlayerData.job = job
    end)
end