/* Shit-code created by laVashik
Protected by the MIT license. Credits: required when used
The code is a tracing method for a game engine using BBoxes (Bounding Boxes) instead of collision meshes to detect collision between objects.
The method is made to compensate for the broken TraceLine() function built into the engine which only detects collision with world geometry and ignores entities.

TRACE function:
    The TRACE function is the main function in this code.
    It takes in two arguments, startpos and endpos, representing the start and end points of the trace.
    There are two optional parameters, ignoremask and filter, which allow for fine-tuning of the trace.
    The function returns an array containing two elements, [hitpos, ent], where hitpos is the position where the trace ended and ent is the entity it collided with.
    If the trace didn't collide with anything, ent will be set to null.

How TRACE works:
    The TRACE function uses the FastTraceEnd function to find the end point of the trace and uses that as a reference point to further refine the trace using smaller steps.
    The function IgnoreTest is used to check whether the entity the trace is about to collide with is in the ignore list or not.
    If it isn't, the function drawbox is called and the TRACE function returns [Ray_part, ent].
    If the filter parameter was set to true, the function will instead store the collision point in an array all_steps and check if the entity it collided with is in the list of captured entities.
    If it is, the function will return [Ray_part, ent].
    If the trace didn't collide with anything or the filter parameter was set to true and the trace only collided with ignored entities, the TRACE function will return [hitpos, null].
*/



//----------SETTINGS----------\\
Trace_IgnoreClass <- ["player","info_target","viewmodel","weapon_","func_illusionary","info_particle_system",
    "trigger_","phys_","env_sprite","point_","vgui","physicsclonearea","env_beam","func_breakable"] // Entities to ignore. Can be specified as a mask, for example (trigger_) will ignore all triggers.

Trace_PriorityClass <- ["trigger_portal_cleanser"] // Entities that take priority over Trace_IgnoreClass.

traceErrorCoefficient <- 1000 // The larger the value, the more accurate the trace but the higher the load.

//-----------------------------------------------------\\

function FastTraceEnd(startpos,endpos) // Function to get the hitpoint, ignoring all entities.
    return startpos + (endpos - startpos) * (TraceLine(startpos, endpos, null))

function Trace(startpos,endpos,ignoremask=null) // Function to get the hitpoint with entity information [0], and the entity itself [1].
/* Arguments:
startpos - Vector of the start point
endpos - Vector of the end point
ignoremask - handle of the entity to ignore
*/
{        
    local hitpos = FastTraceEnd(startpos,endpos) // Get the hit position from FastTraceEnd function
    local dist = hitpos-startpos // Calculate the distance between start and hit positions
    local dist_coeff = abs(dist.Length() / traceErrorCoefficient)+1 // Calculate distance coefficient for more precise tracing
    local step = dist.Length() / 14 / dist_coeff // Calculate the number of steps based on distance and distance coefficient

    for (i <- 0; i < step; i++) // Iterate through each step
    {
        local Ray_part = startpos + dist * (i / step) // Calculate the ray position for the current step
            for(local ent;ent = Entities.FindByClassnameWithin(ent, "*",Ray_part,5*dist_coeff);) // Find the entity at the ray point.
                if(IgnoreTest(ent,ignoremask) && ent) // If entity is not ignored and exists, return the hit position and entity
                    return [Ray_part,ent]
    }
    return [hitpos,null] // If there is no filter, return the hit position and null entity
}

function IgnoreTest(ent,ignoremask) { 
    // Iterate through entities in Trace_IgnoreClass and check if they match the classname of ent.
    foreach(ignore in Trace_IgnoreClass) if(ent.GetClassname().find(ignore)>=0)
    {
        // Check if the entity has a classname that is in the Trace_PriorityClass array.
        local x = true
        foreach(Priority in Trace_PriorityClass) if(ent.GetClassname()==Priority) x=false
        // If the classname is not in Trace_PriorityClass, return false (i.e. do not ignore).
        if(x) return false; 
    }
    // If ignoremask is an array, iterate through the array and return false if ent matches an element of the array.
    if(type(ignoremask)=="array")
    {
        foreach (mask in ignoremask) if(mask==ignoremask) return false
    }
    // If ignoremask is not an array and ent matches ignoremask, return false.
    else if(ignoremask && ent==ignoremask) return false
    // Otherwise, return true (i.e. ignore).
    return true
}
