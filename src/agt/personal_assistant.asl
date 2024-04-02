// personal assistant agent

/* Initial beliefs */
natural_light("0").
artifical_light("1").

best_option :- natural_light("0").

/* Initial goals */ 
// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
@start_plan
+!start : true <-
    .print("Starting Personal Assistant...");
    !setupDweetArtifact(Id);
    sendMessage("test").

@setup_dweet_artifact
+!setupDweetArtifact(Dweet): true <-
    makeArtifact("dweet", "room.DweetArtifact", [], Dweet). /* Exercise 1.1 */

+upcoming_event(State) : upcoming_event("now") & owner_state("asleep") <-
    .print("Broadcasting event");
    .broadcast(tell, increaseIlluminance).



/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
