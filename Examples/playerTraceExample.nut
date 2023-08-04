IncludeScript("portal2-BBoxCast/bboxcast.nut")

// Custom settings for ignoring certain classes of entities
customSettings <- {
    ignoreClass = ["viewmodel", "weapon_", "info_target", "func_illusionary"]
}

lastEntity <- null

// Loop function for continuous ray tracing
function LoopFunction()
{
    // Perform a trace from the player's eyes with a maximum distance of 1000 units using custom settings
    local bboxTrace = bboxcast.TracePlayerEyes(1000, null, customSettings)
    DebugDrawBox(bboxTrace.GetHitpos(), Vector(2, 2, 2) * -1, Vector(2, 2, 2), 255, 255, 255, 125, FrameTime() * 2)

    local entity = bboxTrace.GetEntity()

    // Reset color for the previously hit entity
    if (lastEntity != entity) {
        EntFireByHandle(lastEntity, "Color", "255 255 255", 0, null, null)
    }

    // Handle whether the trace hit the world or an entity
    if (bboxTrace.DidHitWorld()) {
        entity = "Worldspawn"
    }
    else {
        // Set color for the currently hit entity
        EntFireByHandle(entity, "Color", "255 125 0", 0, null, null)
        lastEntity = entity
    }

    printl("You are looking at: " + entity)

    // Schedule the next iteration of the loop
    EntFireByHandle(self, "runscriptcode", "LoopFunction()", FrameTime(), null, null)
}

// Start the loop function
LoopFunction()

// Additional commands to configure the environment
EntFireByHandle(self, "runscriptcode", "SendToConsole(\"sv_alternateticks 0\")", 1, null, null)
EntFireByHandle(self, "runscriptcode", "SendToConsole(\"developer 1\")", 1, null, null)