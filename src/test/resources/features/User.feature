@user @run
Feature: User

  Background:
    Given base url $(env.base_url)
    And header Content-Type = application/json


  @findAllUsersOnWorkspace
  Scenario: Find all users on workspace
    Given call Project.feature@addNewProject
    And header x-api-key = $(env.x_api_key)
    And endpoint /v1/workspaces/{{workspaceId}}/users
    When execute method GET
    Then the status code should be 200
    * define userId = response[0].id





