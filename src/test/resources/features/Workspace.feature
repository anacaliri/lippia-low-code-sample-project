@workspace @run
Feature: Workspace

  Background:
    Given base url $(env.base_url)
    And header x-api-key = $(env.x_api_key)
    And header Content-Type = application/json


  @getAllMyWorkspaces
  Scenario: Get all my workspaces
    Given endpoint $(env.version)/workspaces
    When execute method GET
    Then the status code should be 200
    * define workspaceId = response[0].id

  @addNewWorkspace
  Scenario Outline: Add new workspace
    Given endpoint $(env.version)/workspaces
    And body newWorkspace
    And set value <workspaceName> of key name in body jsons/bodies/newWorkspace.json
    When execute method POST
    Then the status code should be 201
    * define workspaceId = response.id
    * define workspaceName = response.name
    Examples:
      | workspaceName      |
      | Lippia Low Code 19 |

  @failAddNewWorkspace
  Scenario Outline: Fail to add new workspace due to <reason>
    Given endpoint $(env.version)/workspaces
    And body newWorkspace
    And set value <workspaceName> of key name in body jsons/bodies/newWorkspace.json
    When execute method POST
    Then the status code should be 400
    And response should be message = <message>
    Examples:
      | reason         | workspaceName                                                                                                                                                                                                                                                                                                                                                                  | message                                                    |
      | name too short | L                                                                                                                                                                                                                                                                                                                                                                              | Workspace name has to be between 2 and 250 characters long |
      | name too long  | Lorem ipsum dolor sit amet consectetur adipiscing elit in, euismod curae tempor vestibulum vehicula cursus lacus, pharetra viverra lacinia dignissim vulputate a hac. Phasellus diam nibh nulla laoreet sociis tortor eget integer nascetur tristique, eros nam fames hac eu vel cursus enim pulvinar, feugiat congue quisque sodales natoque iaculis facilisi conubia aliquam | Workspace name has to be between 2 and 250 characters long |

  @getWorkspaceInfo
  Scenario: Get workspace info
    Given call Workspace.feature@addNewWorkspace
    And endpoint /v1/workspaces/{{workspaceId}}
    When execute method GET
    Then the status code should be 200
