::defaulSettings <- {
    ignoreClass = ["info_target", "viewmodel", "weapon_", "func_illusionary", "info_particle_system",
    "trigger_", "phys_", "env_sprite", "point_", "vgui", "physicsclonearea", "env_beam", "func_breakable"],
    priorityClass = [],
    ErrorCoefficient = 1000 
}


class bboxcast {

    startpos = null;
    endpos = null;
    ignoremask = null;
    traceSettings = null;

    traceResult = null;

    constructor(startpos, endpos, ignoremask = null, settings = ::defaulSettings) {
        this.startpos = startpos;
        this.endpos = endpos;
        this.ignoremask = ignoremask
        this.traceSettings = settings
        Trace(startpos, endpos, ignoremask)
    }

    function GetStartPos() {
        return startpos
    }

    function GetEndPos() {
        return endpos
    }

    function GetHitpos() {
        return traceResult[0]
    }

    function GetEntity() {
        return traceResult[1]
    }

    function DidHit() {
        return GetFraction() != 1
    }

    function DidHitWorld() {
        return (!traceResult[1] && DidHit())
    }

    function GetFraction() {
        return _GetDist(startpos, traceResult[0]) / _GetDist(startpos, endpos)
    }

    function FastTraceEnd(startpos,endpos) {
        return startpos + (endpos - startpos) * (TraceLine(startpos, endpos, null))
    }


    function Trace(startpos, endpos, ignoremask) {
        local hitpos = FastTraceEnd(startpos, endpos) // Get the hit position from FastTraceEnd function
        local dist = hitpos - startpos // Calculate the distance between start and hit positions
        local dist_coeff = abs(dist.Length() / traceSettings.ErrorCoefficient) + 1 // Calculate distance coefficient for more precise tracing
        local step = dist.Length() / 14 / dist_coeff // Calculate the number of steps based on distance and distance coefficient

        for (local i = 0; i < step; i++) // Iterate through each step
        {
            local Ray_part = startpos + dist * (i / step) // Calculate the ray position for the current step
                for(local ent;ent = Entities.FindByClassnameWithin(ent, "*", Ray_part, 5 * dist_coeff);) // Find the entity at the ray point.
                    if(_checkEntityIsIgnored(ent,ignoremask) && ent) 
                        return traceResult = [Ray_part, ent]
        }

        return traceResult = [hitpos, null] 
    }

    function _checkEntityIsIgnored(ent, ignoremask) {
        foreach (ignore in traceSettings.ignoreClass) {
            if (ent.GetClassname().find(ignore) >= 0) {
                local isPriority = false;
                foreach (priority in traceSettings.priorityClass) {
                    if (ent.GetClassname() == priority) {
                        isPriority = true;
                        break;
                    }
                }
                if (!isPriority) {
                    return false;
                }
            }
        }

        if (type(ignoremask) == "array") {
            foreach (mask in ignoremask) {
                if (mask == ignoremask) {
                    return false;
                }
            }
        } else if (ignoremask && ent == ignoremask) {
            return false;
        }

        return true;
    }

    function _GetDist(start, end) {
        return (start - end).Length()
    }

    function _tostring() {
        return "Bboxcast | \nstartpos: " + startpos + ", \nendpos: " + endpos + ", \nhitpos: " + traceResult[0] + ", \nent: " + traceResult[1] + "\n========================================================="
    }
}

printl("bboxcast successfully initialized\nMade by laVashik")