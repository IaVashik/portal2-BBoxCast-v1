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
       - ignoreEnt (optional): an array of entities to be ignored during tracing
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

Version <- "1.3.0"
::defaulSettings <- {
    ignoreClass = ["info_target", "viewmodel", "weapon_", "func_illusionary", "info_particle_system",
    "trigger_", "phys_", "env_sprite", "point_", "vgui", "physicsclonearea", "env_beam", "func_breakable"],
    priorityClass = [],
    ErrorCoefficient = 1500 
}

// A class for performing bbox-based ray tracing in Portal 2
class bboxcast {
    startpos = null;
    endpos = null;
    hitpos = null;
    hitent = null;
    surfaceNormal = null;
    ignoreEnt = null;
    traceSettings = null;

    constructor(startpos, endpos, ignoreEnt = null, settings = ::defaulSettings) {
        this.startpos = startpos;
        this.endpos = endpos;
        this.ignoreEnt = ignoreEnt
        this.traceSettings = _checkSettings(settings)
        local result = this.Trace(startpos, endpos, ignoreEnt)
        this.hitpos = result.hit
        this.hitent = result.ent
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
        return hitpos
    }

    // Get the entity that was hit by the ray
    function GetEntity() {
        return hitent
    }

        function GetIngoreEntities() {
            return ignoreEnt
        }

    // Check if the ray hit any object or entity
    function DidHit() {
        return GetFraction() != 1
    }

    // Check if the ray hit the world (no entity)
    function DidHitWorld() {
        return (!hitent && DidHit())
    }

    // Get the fraction of the ray's path that was traversed before hitting an entity
    function GetFraction() {
        return _GetDist(startpos, hitpos) / _GetDist(startpos, endpos)
    }

    // Experimental function
    function GetImpactNormal() { 
        // If the surface normal is already calculated, return it
        if(surfaceNormal)
            return surfaceNormal
            
        local intersectionPoint = hitpos

        // Set the deviation value for the trace
        local deviation = 1; 

        // Calculate the normalized direction vector from startpos to hitpos
        local dir = (hitpos - startpos)
        dir.Norm()

        // Calculate offset vectors perpendicular to the trace direction
        local offset1 = Vector(0, 0, deviation)
        local offset2 = dir.Cross( offset1 )

        // Calculate new start positions for two additional traces
        local newStart1 = startpos + offset1
        local newStart2 = startpos + offset2

        // Perform two additional traces to find intersection points
        // local intersectionPoint1 = _TraceEnd(newStart1, newStart1 + (hitpos - startpos)) // Cheap method
        // local intersectionPoint2 = _TraceEnd(newStart2, newStart2 + (hitpos - startpos))
        local intersectionPoint1 = Trace(newStart1, newStart1 + dir * 8000, ignoreEnt).hit
        local intersectionPoint2 = Trace(newStart2, newStart2 + dir * 8000, ignoreEnt).hit

        // Calculate two edge vectors from intersection point to hitpos
        local edge1 = intersectionPoint - intersectionPoint1;
        local edge2 = intersectionPoint - intersectionPoint2;

        // Calculate the cross product of the two edges to find the normal vector
        surfaceNormal = edge1.Cross(edge2)
        surfaceNormal.Norm()

        return surfaceNormal
    }

    // Perform the main trace by iterating through steps and checking for entities
    function Trace(startpos, endpos, ignoreEnt) {
        // Get the hit position from the fast trace
        local hitpos = _TraceEnd(startpos, endpos)
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
                if (_checkEntityIsIgnored(ent, ignoreEnt) && ent) {
                    return {hit = Ray_part, ent = ent}
                }
            }
        }

        return {hit = hitpos, ent = null}
    }

    // Perform a bboxcast trace from the player's eyes
    function TracePlayerEyes(distance, ignoreEnt = null, settings = ::defaulSettings) {
        // Get the player's eye position and forward direction
        local eyePosition = ::eyePointEntity.GetOrigin()
        local eyeDirection = ::eyePointEntity.GetForwardVector()

        // Calculate the start and end positions of the trace
        local startpos = eyePosition
        local endpos = eyePosition + eyeDirection * distance

        // Check if any entities should be ignored during the trace
        if (ignoreEnt) {
            // If ignoreEnt is an array, append the player entity to it
            if (type(ignoreEnt) == "array") {
                ignoreEnt.append(GetPlayer())
            }
            // If ignoreEnt is a single entity, create a new array with both the player and ignoreEnt
            else {
                ignoreEnt = [GetPlayer(), ignoreEnt]
            }
        }
        // If no ignoreEnt is provided, ignore the player only
        else {
            ignoreEnt = GetPlayer()
        }

        // Perform the bboxcast trace and return the trace result
        return bboxcast(startpos, endpos, ignoreEnt, settings)
    }

    // Check if an entity should be ignored based on the provided settings
    function _checkEntityIsIgnored(ent, ignoreEnt) {
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

        if (type(ignoreEnt) == "array") {
            foreach (mask in ignoreEnt) {
                if (mask == ent) {
                    return false;
                }
            }
        } else if (ignoreEnt && ent == ignoreEnt) {
            return false;
        }

        return true;
    }

    // Calculate the distance between two points
    function _GetDist(start, end) {
        return (start - end).Length()
    }

    // Internal function
    function _TraceEnd(startpos,endpos) {
        return startpos + (endpos - startpos) * (TraceLine(startpos, endpos, null))
    }

    function _checkSettings(settings) {
        // Check if settings is already in the correct format
        if (settings.len() == 3)
            return settings
        
        // Check and assign default values if missing
        if (!("ignoreClass" in settings)) {
            settings["ignoreClass"] <- ::defaulSettings["ignoreClass"]
        }
        if (!("priorityClass" in settings)) {
            settings["priorityClass"] <- ::defaulSettings["priorityClass"]
        }   
        if (!("ErrorCoefficient" in settings)) {
            settings["ErrorCoefficient"] <- ::defaulSettings["ErrorCoefficient"]
        }

        return settings
    }

    // Convert the bboxcast object to string representation
    function _tostring() {
        return "Bboxcast | \nstartpos: " + startpos + ", \nendpos: " + endpos + ", \nhitpos: " + hitpos + ", \nent: " + hitent + "\n========================================================="
    }
}

// Store disabled entities' bounding boxes
disabled_entity <- {}

// Disable an entity by setting its size to (0, 0, 0)
function CorrectDisable() {
    EntFireByHandle(caller, "Disable", "", 0, null, null)
    local entIndex = caller.entindex.tostring()
    if( !(entIndex in disabled_entity)) {
        disabled_entity[entIndex] <- {min = caller.GetBoundingMins(), max = caller.GetBoundingMaxs()}
    }
    caller.SetSize(Vector(0, 0, 0), Vector(0, 0, 0))
}

// Enable a previously disabled entity and restore its original size
function CorrectEnable() {
    EntFireByHandle(caller, "Enable", "", 0, null, null)
    local entIndex = caller.entindex.tostring()
    if( entIndex in disabled_entity ) {
        local BBox = disabled_entity[entIndex]
        caller.SetSize(BBox.min, BBox.max)
    }
}

function Init() {
    if(!Entities.FindByName(null, "eyeControl")) {
        // Creating and Configuring Entities for Eye Management
        ::eyeControlEntity <- Entities.CreateByClassname( "logic_measure_movement" )
        ::eyeControlEntity.__KeyValueFromString("targetname", "eyeControl")
        ::eyeControlEntity.__KeyValueFromInt("measuretype", 1)

        ::eyePointEntity <- Entities.CreateByClassname( "info_target" )
        ::eyePointEntity.__KeyValueFromString("targetname", "eyePoint")
        
        // Establishing links between entities and launching functionality
        EntFire("eyeControl","setmeasuretarget", "!player");
        EntFire("eyeControl","setmeasurereference", "eyeControl");
        EntFire("eyeControl","SetTargetReference", "eyeControl");
        EntFire("eyeControl","Settarget", "eyePoint");
        EntFire("eyeControl","Enable")
    }   
    
    printl("===================================\nbboxcast successfully initialized\nAuthor: laVashik\n" +
        "GitHub: https://github.com/IaVashik\nVersion: " + Version + "\n===================================")
}

Init()