@project
Feature: Project

  Background:
    Given base url $(env.base_url)
    And header Content-Type = application/json


  @getAllProjectsOnWorkspace
  Scenario: Get all projects on workspace
    Given call Workspace.feature@getWorkspaceInfo
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects
    When execute method GET
    Then the status code should be 200

  @addNewProject
  Scenario Outline: Add new project
    Given call Workspace.feature@addNewWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects
    And body newProject
    And set value <projectName> of key name in body jsons/bodies/newProject.json
    When execute method POST
    Then the status code should be 201
    * define projectId = response.id
    Examples:
      | projectName             |
      | Lippia Low Code Project |

  @failAddNewProjectDueToAuthorization
  Scenario Outline: Fail to add new project due to api key not exist
    Given call Workspace.feature@getWorkspaceInfo
    And header x-api-key = <key>
    And endpoint /v1/workspaces/{{workspaceId}}/projects
    And body newProject
    And set value <projectName> of key name in body jsons/bodies/newProject.json
    When execute method POST
    Then the status code should be 401
    And response should be message = <message>
    Examples:
      | key                                              | projectName       | message                |
      | ZTcy11QxYWItZTAzMS00OGZhLThmNjktZWU2ODk0NzAAZmFj | Lippia Low Code 3 | Api key does not exist |

  @failAddNewProjectDueToAccessDenied
  Scenario Outline: Fail to add new project due to access denied
    Given call Workspace.feature@addNewWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/6659057aca17ee61625151d7/projects
    And body newProject
    And set value <projectName> of key name in body jsons/bodies/newProject.json
    When execute method POST
    Then the status code should be 403
    And response should be message = <message>
    Examples:
      | projectName       | message       |
      | Lippia Low Code X | Access Denied |

  @failAddNewProjectDueToName
  Scenario Outline: Fail to add new project due to <reason>
    Given call Workspace.feature@addNewWorkspace
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects
    And body newProject
    And set value <projectName> of key name in body jsons/bodies/newProject.json
    When execute method POST
    Then the status code should be 400
    And response should be message = <message>
    Examples:
      | reason         | projectName                                                                                                                                                                                                                                                                                                                                                                     | message                                                  |
      | name too short | L                                                                                                                                                                                                                                                                                                                                                                               | Project name has to be between 2 and 250 characters long |
      | name too long  | Lorem ipsum dolor sit amet consectetur adipiscing elit in, euismod curae tempor vestibulum vehicula cursus lacus, pharetra viverra lacinia dignissim vulputate a hac. Phasellus diam nibh nulla laoreet sociis tortor eget integer nascetur tristique, eros nam fames hac eu vel cursus enim pulvinar, feugiat congue quisque sodales natoque iaculis facilisi conubia aliquam. | Project name has to be between 2 and 250 characters long |

  @findProjectById
  Scenario: Find project by id
    Given call Project.feature@addNewProject
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects/{{projectId}}
    When execute method GET
    Then the status code should be 200

  @failFindProjectByIdDueToMissingProject
  Scenario Outline: Fail finding new project
    Given call Project.feature@addNewProject
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects/<projectId>
    When execute method GET
    Then the status code should be 400
    And response should be message = <message>
    Examples:
      | projectId                | message                             |
      | 665907335ef4fd678d937e3f | Project doesn't belong to Workspace |

  @failFindProjectByIdDueToAuthorization
  Scenario Outline: Fail finding new project due to authorization
    Given call Project.feature@addNewProject
    And header x-api-key = <key>
    And endpoint /v1/workspaces/{{workspaceId}}/projects/{{projectId}}
    When execute method GET
    Then the status code should be 401
    And response should be message = <message>
    Examples:
      | key                                              | message                |
      | ZTcy11QxYWItZTAzMS00OGZhLThmNjktZWU2ODk0NzAAZmFj | Api key does not exist |

  @updateProjectOnWorkspace
  Scenario Outline: Update project on workspace
    Given call Project.feature@findProjectById
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects/{{projectId}}
    And  set value <name> of key name in body jsons/bodies/updateProject.json
    When execute method PUT
    Then the status code should be 200
    And response should be name = pepe
    Examples:
      | name |
      | pepe |

  @failUpdateProjectOnWorkspace
  Scenario Outline: Fail to update project on workspace
    Given call Project.feature@findProjectById
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/projects/{{projectId}}
    And  set value <name> of key name in body jsons/bodies/updateProject.json
    When execute method PUT
    Then the status code should be 400
    Examples:
      | name |
      |      |




