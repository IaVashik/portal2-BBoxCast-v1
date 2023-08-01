IncludeScript("portal2-BBoxCast/bboxcast.nut")

// Function to print trace information
function PrintTraceInfo(trace)
{
    printl("Start Position: " + trace.GetStartPos())
    printl("End Position: " + trace.GetEndPos())
    printl("Hit Position: " + trace.GetHitpos())
    printl("Hit Entity: " + trace.GetEntity())
    printl("Did Hit: " + trace.DidHit())
    printl("Did Hit World: " + trace.DidHitWorld())
    printl("Fraction Traversed: " + trace.GetFraction())
}

// Function to perform a single ray trace
function TestRay()
{
    local startpos = EntityGroup[0].GetOrigin()
    local endpos = EntityGroup[1].GetOrigin()

    // Perform bboxcast trace from startpos to endpos
    local bboxTrace = bboxcast(startpos, endpos)
    
    // Print trace information
    PrintTraceInfo(bboxTrace)

    // Visualize the trace by drawing a line from startpos to hitpos
    DebugDrawLine(startpos, bboxTrace.GetHitpos(), 255, 255, 255, false, 1)

    // If the trace hit an entity, move another entity to the hit position and enable its output
    if (bboxTrace.DidHit()) {
        EntityGroup[2].SetOrigin(bboxTrace.GetHitpos())
        EntFire("hitpos", "enable")
    }
    else {
        EntFire("hitpos", "disable")
    }
}

// Function to continuously perform ray traces until a specified time
function TestRayLoop(time = null)
{
    local startpos = EntityGroup[0].GetOrigin()
    local endpos = EntityGroup[1].GetOrigin()

    // If no time is specified, calculate a time value based on current time
    if (!time) time = abs(Time()) + 11

    // Exit the loop when the specified time is reached
    if (abs(Time()) == time)
        return

    // Perform bboxcast trace from startpos to endpos
    local bboxTrace = bboxcast(startpos, endpos)
    
    // Print trace information
    PrintTraceInfo(bboxTrace)

    // Visualize the trace by drawing a line from startpos to hitpos
    DebugDrawLine(startpos, bboxTrace.GetHitpos(), 255, 0, 255, false, FrameTime() * 2)

    // If the trace hit an entity, move another entity to the hit position and enable its output
    if (bboxTrace.DidHit()) {
        EntityGroup[2].SetOrigin(bboxTrace.GetHitpos())
        EntFire("hitpos", "enable")
    }
    else {
        EntFire("hitpos", "disable")
    }

    // Schedule the next iteration of the loop
    EntFireByHandle(self, "runscriptcode", "TestRayLoop(" + time + ")", FrameTime(), null, null)
}

SendToConsole("sv_alternateticks 0")