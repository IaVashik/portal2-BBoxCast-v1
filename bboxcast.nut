/*
    BBoxCast - VScripts library for TraceLine with entity support in Portal 2
    
    Author: lavashik
    Credits: This library was created by laVashik. Please give credit when using it.
    
    This library provides a bbox-based ray tracing functionality in Portal 2. 
    It enables the ray to hit entities using their bbox, unlike the regular traceline() function which ignores entities and only hits world geometry.
    
    Usage:
    1. Include this library in your VScript.
    2. Create an instance of the bboxcast class by providing the following parameters:
       - startpos: the starting position of the ray
       - endpos: the ending position of the ray
       - ignoremask (optional): an array of entities to be ignored during tracing
       - settings (optional): custom settings for the trace, if any
    3. Use the various methods of the bboxcast instance to retrieve trace information:
       - GetStartPos(): returns the starting position of the ray
       - GetEndPos(): returns the ending position of the ray
       - GetHitpos(): returns the position where the ray hit an entity
       - GetEntity(): returns the entity that was hit by the ray
       - DidHit(): checks if the ray hit any object or entity
       - DidHitWorld(): checks if the ray hit the world (no entity)
       - GetFraction(): returns the fraction of the ray's path that was traversed before hitting an entity
    4. Alternatively, you can directly modify the bboxcast class to suit your specific needs.
*/

local Version = "1.2.0"
::defaulSettings <- {
    ignoreClass = ["info_target", "viewmodel", "weapon_", "func_illusionary", "info_particle_system",
    "trigger_", "phys_", "env_sprite", "point_", "vgui", "physicsclonearea", "env_beam", "func_breakable"],
    priorityClass = [],
    ErrorCoefficient = 1000 
}

// A class for performing bbox-based ray tracing in Portal 2
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

    // Get the starting position of the ray
    function GetStartPos() {
        return startpos
    }

    // Get the ending position of the ray
    function GetEndPos() {
        return endpos
    }

    // Get the position where the ray hit
    function GetHitpos() {
        return traceResult[0]
    }

    // Get the entity that was hit by the ray
    function GetEntity() {
        return traceResult[1]
    }

    // Check if the ray hit any object or entity
    function DidHit() {
        return GetFraction() != 1
    }

    // Check if the ray hit the world (no entity)
    function DidHitWorld() {
        return (!traceResult[1] && DidHit())
    }

    // Get the fraction of the ray's path that was traversed before hitting an entity
    function GetFraction() {
        return _GetDist(startpos, traceResult[0]) / _GetDist(startpos, endpos)
    }

    // Internal function
    function FastTraceEnd(startpos,endpos) {
        return startpos + (endpos - startpos) * (TraceLine(startpos, endpos, null))
    }

    // Perform the main trace by iterating through steps and checking for entities
    function Trace(startpos, endpos, ignoremask) {
        // Get the hit position from the fast trace
        local hitpos = FastTraceEnd(startpos, endpos)
        // Calculate the distance between start and hit positions
        local dist = hitpos - startpos
        // Calculate a distance coefficient for more precise tracing based on distance and error coefficient
        local dist_coeff = abs(dist.Length() / traceSettings.ErrorCoefficient) + 1
        // Calculate the number of steps based on distance and distance coefficient
        local step = dist.Length() / 14 / dist_coeff

        // Iterate through each step
        for (local i = 0; i < step; i++) {
            // Calculate the ray position for the current step
            local Ray_part = startpos + dist * (i / step)
            // Find the entity at the ray point
            for (local ent;ent = Entities.FindByClassnameWithin(ent, "*", Ray_part, 5 * dist_coeff);) {
                if (_checkEntityIsIgnored(ent,ignoremask) && ent) 
                    return traceResult = [Ray_part, ent]
            }
        }

        return traceResult = [hitpos, null] 
    }

    // Check if an entity should be ignored based on the provided settings
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

    // Calculate the distance between two points
    function _GetDist(start, end) {
        return (start - end).Length()
    }

    // Convert the bboxcast object to string representation
    function _tostring() {
        return "Bboxcast | \nstartpos: " + startpos + ", \nendpos: " + endpos + ", \nhitpos: " + traceResult[0] + ", \nent: " + traceResult[1] + "\n========================================================="
    }
}

printl("===================================\nbboxcast successfully initialized\nAuthor: laVashik\nGitHub: https://github.com/IaVashik\nVersion: " + Version + "\n===================================")
