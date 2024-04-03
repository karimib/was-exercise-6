// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").
plays(initiator,personal_assistant).

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
    set_state("raised").

@blinds_lower_plan
+!blinds_lower : true <-
    set_state("lowered").

@set_state_plan
+!set_state(newState) : true <- 
   invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", newState);
   -+blinds(newState).

+blinds(State) : true <-
    .print("Blinds are ", State);
    .send(personal_assistant, tell, blinds(State)).


     /* Plans */
// send a message to initiator introducing myself // as a participant
+plays(initiator,In)
        :  .my_name(Me)
        <- .send(In,tell,introduction(participant,Me)).

// answer a Call For Proposal
@c1 +cfp(CNPId,Task)[source(A)]
    : plays(initiator,A) & blinds(State)
    <- +proposal(CNPId,blinds_raise,Offer); // remember my proposal
            .send(A,tell,propose(CNPId,Offer)).

@r1 +accept_proposal(CNPId)
    : proposal(CNPId,Task,Offer) & true
    <- .print("My proposal ’",Offer,"’ won CNP ",CNPId," for ",Task,"!");
        !!set_state("raised")[source(blinds_controller)].
           // do the task and report to initiator

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }