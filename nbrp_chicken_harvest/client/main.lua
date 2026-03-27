ChickenHarvest = ChickenHarvest or {}
ChickenHarvest.Busy = false
ChickenHarvest.TextVisible = false

function ChickenHarvest.ShowText()
    if ChickenHarvest.TextVisible then return end
    lib.showTextUI(Config.TextUI)
    ChickenHarvest.TextVisible = true
end

function ChickenHarvest.HideText()
    if not ChickenHarvest.TextVisible then return end
    lib.hideTextUI()
    ChickenHarvest.TextVisible = false
end
