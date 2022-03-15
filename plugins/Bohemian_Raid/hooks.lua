local _, E = ...

function E:Hook()
    hooksecurefunc("RaidGroupFrame_Update", E.RaidGroupFrame_Update)
end
