Config = {}

Config.Framework = nil

Citizen.CreateThread(function()
    if GetResourceState('es_extended') == 'started' then
        Config.Framework = 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        Config.Framework = 'QBCore'
    else
        print('No se detectó ESX ni QBCore. El script puede no funcionar correctamente.')
    end
end)

Config.AllowedJobs = {
    ['mechanic'] = true,
    ['police'] = true
}

Config.HandlingProperties = {
    'fDriveInertia',
    'fSteeringLock',
    'fTractionCurveMax',
    'fTractionCurveMin',
    'fSuspensionForce',
    'fSuspensionCompDamp',
    'fSuspensionReboundDamp',
    'fSuspensionUpperLimit',
    'fSuspensionLowerLimit',
    'fSuspensionRaise',
    'fCollisionDamageMult'
}