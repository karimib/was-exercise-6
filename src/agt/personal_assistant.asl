// personal assistant agent

/* Initial beliefs */
natural_light(0).
artifical_light(1).

best_option :- natural_light("0").

plays(initiator,personal_assistant).

all_proposals_received(CNPId) :- .count(introduction(participant,_),NP) & // number of participants
  .count(propose(CNPId,_), NO) &
  .count(refuse(CNPId), NR) &
  NP = NO + NR.

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

+upcoming_event("now"): owner_state("asleep") <-
    .print("Broadcasting event");
    !!startCNP(1, increaseIlluminance)[source(personal_assistant)].


+plays(initiator,In)
        :  .my_name(Me)
        <- .send(In,tell,introduction(participant,Me)).


+!startCNP(Id,Object) <- .wait(2000); // wait participants introduction 
    +cnp_state(Id,propose); // remember the state of the CNP 
    .findall(Name,introduction(participant,Name),LP); 
    .print("Sending CFP to ",LP); 
    .send(LP,tell,cfp(Id,Object)); 
    .concat("+!contract(",Id,")",Event);
// the deadline of the CNP is now + 4 seconds, so
// the event +!contract(Id) is generated at that time 
    .at("now +4 seconds", Event).

@r1 
+propose(CNPId,Offer)
   :  cnp_state(CNPId,propose) & all_proposals_received(CNPId)
   <- !contract(CNPId).

@r2 
+refuse(CNPId)
   :  cnp_state(CNPId,propose) & all_proposals_received(CNPId)
   <- !contract(CNPId).

@lc1[atomic]
+!contract(CNPId)
   :  cnp_state(CNPId,propose)
   <- -+cnp_state(CNPId,contract);
    .findall(offer(O,A),propose(CNPId,O)[source(A)],L); 
    .print("Offers are ",L);
    L \== []; // constraint the plan execution to at least one offer 
    .min(L,offer(WOf,WAg)); // sort offers, the first is the best 
    .print("Winner is ",WAg," with ",WOf); 
    !announce_result(CNPId,L,WAg);
    -+cnp_state(Id,finished).
    // nothing todo, the current phase is not ’propose’ @lc2 +!contract(CNPId).
    -!contract(CNPId)
    <- .print("CNP ",CNPId," has failed!").
    +!announce_result(_,[],_).
    // announce to the winner
    +!announce_result(CNPId,[offer(O,WAg)|T],WAg)
    <- .send(WAg,tell,accept_proposal(CNPId));
        !announce_result(CNPId,T,WAg).
    // announce to others
    +!announce_result(CNPId,[offer(O,LAg)|T],WAg)
    <- .send(LAg,tell,reject_proposal(CNPId));
        !announce_result(CNPId,T,WAg).

@lc2 
+!contract(CNPId).
-!contract(CNPId)
   <- .print("CNP ",CNPId," has failed!").

+!announce_result(_,[],_).
// announce to the winner

+!announce_result(CNPId,[offer(O,WAg)|T],WAg)
   <- .send(WAg,tell,accept_proposal(CNPId));
      !announce_result(CNPId,T,WAg).
// announce to others
+!announce_result(CNPId,[offer(O,LAg)|T],WAg)
   <- .send(LAg,tell,reject_proposal(CNPId));
      !announce_result(CNPId,T,WAg).
/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }
