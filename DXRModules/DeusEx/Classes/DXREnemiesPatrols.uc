class DXREnemiesPatrols extends DXREnemiesBase transient;

function GivePatrols()
{
    local ScriptedPawn p, ps[256];
    local int num, i, b, max;

    l("DXREnemiesPatrols GivePatrols");

    SetSeed("DXREnemiesPatrols selection");
    foreach AllActors(class'ScriptedPawn', p) {
        if(p.Orders != 'DynamicPatrolling') continue;
        if(chance_single(20) || num >= ArrayCount(ps)) {
            // 20% chance to wander instead
            p.SetOrders('Wandering');
            continue;
        }
        ps[num++] = p;
    }

    l("DXREnemiesPatrols got "$num);
    max = 20;
    if(num > max) {
        SetSeed("DXREnemiesPatrols reduce");
        for(i=0; i<max; i++) {
            b = rng(num);
            p = ps[i];
            ps[i] = ps[b];
            ps[b] = p;
        }
        for(i=max; i<num; i++) {
            ps[i].SetOrders('Wandering');
        }
        num = max;
    }

    SetSeed("DXREnemiesPatrols GivePatrols");
    for(i=0; i<num; i++) {
        p = ps[i];
        if(!GivePatrol(p)) {
            warning("failed to GivePatrol to "$p@p.Location);
            p.SetOrders('Wandering');
        }
    }
}

function bool GivePatrol(ScriptedPawn pawn)
{
    local DynamicPatrolPoint p, prev, first;
    local NavigationPoint nps[100], np;
    local string s;
    local int i, q, num;
    local float maxradius, max_z_dist, dist;
    local NavigationPoint quadrants_farthest[4];
    local float quadrants_farthest_dists[4];
    local vector center;// the center of the points is not always where the pawn is

    maxradius = rngrange(750, 0.5, 1.5);
    max_z_dist = 50;
    l("GivePatrol "$pawn@pawn.Location@maxradius@max_z_dist);

    // collect the points we can use and figure out the center of them all
    foreach RadiusActors(class'NavigationPoint', np, maxradius, pawn.Location) {
        if(DynamicPatrolPoint(np) != None) continue;
        if(Abs(pawn.Location.z - np.Location.z) > max_z_dist) continue;
        nps[num++] = np;
        center += np.Location;
    }
    center /= float(num);

    // find the farthest corners of our quadrants
    for(i=0; i<num; i++) {
        q = 0;
        if(nps[i].Location.x > center.x)
            q = 1;
        if(nps[i].Location.y > center.y)
            q = q*-1 + 3;// don't criss-cross the square, go around it like a circle

        dist = VSize(nps[i].Location - center);
        if(dist >= quadrants_farthest_dists[q]) {
            quadrants_farthest_dists[q] = dist;
            quadrants_farthest[q] = nps[i];
        }
    }

    // how many quadrants did we find?
    num=0;
    for(q=0; q<4; q++) {
        if(quadrants_farthest[q] == None) continue;
        num++;
        //quadrants_farthest[q].bHidden = false;
        //quadrants_farthest[q].DrawScale = 2;
    }

    // random chance to ditch 1 or 2 of the points, to step down to a triangle or straight line back and forth
    for(q=0; q<4; q++) {
        if(quadrants_farthest[q] == None) continue;
        if(num > 2 && chance_single(10)) {
            num--;
            quadrants_farthest[q] = None;
        }
    }

    // create the DynamicPatrolPoints
    i=0;
    for(q=0; q<4; q++) {
        if(quadrants_farthest[q] == None) continue;
        prev = p;
        s = string(pawn.name) $ "_" $ (i++);
        p = CreatePoint(quadrants_farthest[q], StringToName(s));

        if(first==None)
            first = p;
        else {
            LinkPoints(prev, p);
        }
    }

    if(first == None) return false;

    LinkPoints(p, first);

    pawn.SetOrders('Patrolling', first.tag, false);
    pawn.FollowOrders(false);
    // skip past the Begin section of the state, because that sets destPoint to None and tries to search inside of a native list of NavigationPoints
    pawn.GotoState('Patrolling', 'Patrol');
    pawn.destPoint = first;

    l("GivePatrol "$pawn$" end "$p@p.Tag$" linking back to "$first@first.Tag);
    return true;
}

function LinkPoints(DynamicPatrolPoint prev, DynamicPatrolPoint next)
{
    local rotator lookAngle;
    prev.Nextpatrol = next.Tag;
    prev.NextPatrolPoint = next;

    // set rotation, similar to Pawn::LookAtVector()
    lookAngle = Rotator(next.Location-prev.Location);
    prev.lookdir = 200 * vector(lookAngle);
}

function DynamicPatrolPoint CreatePoint(NavigationPoint n, Name t)
{
    local int i;
    local DynamicPatrolPoint p;
    p = Spawn(class'DynamicPatrolPoint',, t, n.Location);
    p.pausetime = rngrange(1, 0.1, 5);

    for(i=0; i<16; i++) {
        p.upstreamPaths[i] = n.upstreamPaths[i];
        p.Paths[i] = n.Paths[i];
        p.PrunedPaths[i] = n.PrunedPaths[i];
        p.VisNoReachPaths[i] = n.VisNoReachPaths[i];
    }
    p.visitedWeight = n.visitedWeight;
    p.routeCache = n.routeCache;
    p.cost = n.cost;
    p.ExtraCost = n.ExtraCost;

    p.bEndPoint = n.bEndPoint;
    p.bEndPointOnly = n.bEndPointOnly;
    p.bSpecialCost = n.bSpecialCost;
    p.bOneWayPath = n.bOneWayPath;
    return p;
}
