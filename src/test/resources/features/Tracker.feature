@tracker @run
Feature: Tracker

  Background:
    Given base url $(env.base_url)
    And header Content-Type = application/json

  @addNewTimeEntry
  Scenario Outline: Add new time entry
    Given call User.feature@findAllUsersOnWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries
    And body newTimeEntry
    And set value {{projectId}} of key projectId in body jsons/bodies/newTimeEntry.json
    And set value <start> of key start in body jsons/bodies/newTimeEntry.json
    And set value <end> of key end in body jsons/bodies/newTimeEntry.json
    When execute method POST
    Then the status code should be 201
    * define timeEntryId = response.id
    Examples:
      | start                | end                  |
      | 2020-01-01T00:00:00Z | 2020-01-01T00:30:00Z |

  @failAddNewTimeEntry
  Scenario Outline: Fail to add new time entry due to duration
    Given call Project.feature@addNewProject
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries
    And body newTimeEntry
    And set value {{projectId}} of key projectId in body jsons/bodies/newTimeEntry.json
    And set value <start> of key start in body jsons/bodies/newTimeEntry.json
    And set value <end> of key end in body jsons/bodies/newTimeEntry.json
    When execute method POST
    Then the status code should be 400
    And response should be message = <message>
    Examples:
      | start                | end                  | message                                              |
      | 2020-01-01T00:00:00Z | 2021-01-01T00:00:00Z | Time entry cannot have duration more than 999 hours. |

  @getTimeEntryForAUserOnWorkspace
  Scenario: Get time entries for a user on workspace
    Given call Tracker.feature@addNewTimeEntry
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/user/{{userId}}/time-entries
    When execute method GET
    Then the status code should be 200
    * define timeEntryId = response[0].id

  @updateTimeEntryOnWorkspace
  Scenario Outline: Fail to update time entry on workspace due to use un unenabled features
    Given call Tracker.feature@getTimeEntryForAUserOnWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries/{{timeEntryId}}
    And body updateTimeEntry
    And set value {{projectId}} of key projectId in body jsons/bodies/updateTimeEntry.json
    And set value <type> of key type in body jsons/bodies/updateTimeEntry.json
    When execute method PUT
    Then the status code should be 200
    Examples:
      | type    |
      | REGULAR |

  @failToUpdateTimeEntryOnWorkspaceDueToUnenabledFeature
  Scenario Outline: Fail to update time entry on workspace due to unenabled feature
    Given call Tracker.feature@getTimeEntryForAUserOnWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries/{{timeEntryId}}
    And body updateTimeEntry
    And set value {{projectId}} of key projectId in body jsons/bodies/updateTimeEntry.json
    And set value <type> of key type in body jsons/bodies/updateTimeEntry.json
    When execute method PUT
    Then the status code should be 400
    And response should be message = <message>
    Examples:
      | type    | message                                                                                                   |
      | BREAK   | You dont have permission to create break time entry since break feature is not enabled.                   |
      | HOLIDAY | You dont have permission to create time off and holiday time entry since time off feature is not enabled. |

  @deleteTimeEntry
  Scenario: Delete time entry from workspace
    Given call Tracker.feature@getTimeEntryForAUserOnWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries/{{timeEntryId}}
    When execute method DELETE
    Then the status code should be 204

  @failDeleteTimeEntry
  Scenario: Fail to delete time entry from workspace
    Given call Tracker.feature@getTimeEntryForAUserOnWorkspace
    And header x-api-key = $(env.x_api_key)
    * define timeEntryId = 0
    And endpoint /v1/workspaces/{{workspaceId}}/time-entries/{{timeEntryId}}
    When execute method DELETE
    Then the status code should be 400
    And response should be message = Time entry doesn't belong to Workspace

