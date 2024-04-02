// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) & blinds(State) <-
    .print("Starting blinds controller...");
    makeArtifact("Blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], Blinds);
    .send(personal_assistant, tell, blinds(State)).

@blinds_raise_plan
+!blinds_raise : true <-
    setState("raised").

@blinds_lower_plan
+!blinds_lower : true <-
    setState("lowered").

@set_state_plan
+!setState(newState) : true <- 
   invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", newState);
   -+blinds(newState).

+blinds(State) : true <-
    .print("Blinds are ", State);
    .send(personal_assistant, tell, blinds(State)).

+increaseIlluminance : blinds("lowered") <-
    .print("Blinds are lowered, increasing illuminance...");
    .send(personal_assistant, tell, lights_on_plan).

+increaseIlluminance : blinds("raised") <- 
    .send(personal_assistant, tell, {}).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }