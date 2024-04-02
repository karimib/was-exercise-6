// lights controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url)  & lights(State) <-
    .print("Starting lights manager...");
    makeArtifact("Lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], Lights);
    .send(personal_assistant, tell, lights(State)).

@lights_on_plan
+!lights_on : true <-
    setState("on").

@lights_off_plan
+!ligths_off : true <-
    setState("off").

@set_state_plan
+!setState(newState) : true <- 
   invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", newState);
   -+lights(newState).

+lights(State) : true <- 
    .print("Lights are ", State);
    .send(personal_assistant, tell, lights(State)).

+increaseIlluminance : lights("off") <- 
    .print("Lights are off, increasing illuminance...");
    .send(personal_assistant, tell, {lights_on_plan}).

+increaseIlluminance : lights("on") <- 
    .send(personal_assistant, tell, {}).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }