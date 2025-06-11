# List of scenarios to be tested as they are relevant to Iderha uses

### Latest versions tested: 
- cwl-wes: eec5a317622810d8d70793081e0b9eea646dbd41 (fix_4_iderha)
- cwl-tes: 2b1426b9610c2d56f870691a4857ce56bc28f589 (extend-schema-with-remote-location-requirement)
- pro-tes: eae3c2cfdc4db54b9f51b7b6be796af948149747 (iderha-handle-location-tags-from-task-requirement)
- tesk-api: 1e48cb5d6b7a2a6ace32060a06522769c680e20c (fix_4_iderha)

### Scenario 1

Very basic workflow just to make sure nothing is going wrong with the cluster

**Status**: Request without any workflow parameter are not accepted by WES server, but sending unused parameters (e.g. {"foo":"bar"})
is accepted. Once the request is processed, the workflow runs and print the output in the pod logs.

### Scenario 2

Extension of scenario 1 to check that simple inputs are correctly processed

**Status**: PASSES

### Scenario 3

Extension of scenarios 1 & 2, where the printed message now is picked up and saved as an output

**Status**: PASSES

### Scenario 4

Switching input to a file to be sure these are correctly processed. 
This file is provided as a DRS entry that points to a remote node to test the implicit dispatching

**Status**: PASSES

## Scenario 5

Extension of scenario 4, the message to be displayed in remote node is provided as input

**Status**: PASSES

## Scenario 6

Extension of scenarios 4 & 5. The printed message is now stored as output and should be available

**Status**: PASSES

## Scenario 7

Extension of scenario 3, where the task is executed in a node explicitly given in the inputs

**Status**: PASSES

## Scenario 8

Asking for the execution date to a specific node. 

**Status**: PASSES (not sure the scenario tests the expected behavior)

## Scenario 9

Asking for the execution date to a specific node. 

**Status**: PASSES (not sure the scenario tests the expected behavior)

## Scenario 10

Workflow to retrieve date from a remote node, then to print it in central node

**Status**: PASSES

## Scenario 11

Workflow to retrieve date from central node, then to print it in a remote node

**Status**: PASSES

## Scenario 12

Get date in a remote node, then ask that node again and get the time delta. The time delta is sent to central node for printing

**Status**: PASSES

## Scenario 13

Extension of scenario 12, where getting the timedelta is done in 2 nodes, then compared

**Status**: PASSES

## Scenario 14

Get starting date in central node, compute timedelta in remote node, then print the timedelta in central node

**Status**: PASSES

## Scenario 15

Get date in both central and remote nodes, then calculate timedelta between results

**Status**: PASSES

## Scenario 16

Get date in both remote nodes, then calculate the timedelta between two results in central node

**Status**:

# NOTES

Following issues were found while building and testing scenarios:
- InitialWorkDirRequirement does not work in cluster at the moment, and is unlikely to in the future.\
  The reason is that the initial workdir is built in WES, than transferred to TESK by using a PVC to the same volume.
  In our case, these two services are on different machines (that's the point...) so either I misunderstood how it's supposed to work, or something is very wrong.

- There seems to be a race condition when using twice the same task in a workflow. To avoid it, I set enableReuse as False
  in the workflows it may happen

- It seems that WorkflowStep directly written in a Workflow file cannot be correctly parsed when remote_storage_url
  is set. To avoid it I wrote these in different files.