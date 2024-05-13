*** Settings ***
Library  RequestsLibrary
Library  String
Library  Collections   
Library  FakerLibrary    locale=pt_BR 

*** Variables ***
${url}                       https://chips.qacoders-academy.com.br
${mail}                      sysadmin@qacoders.com
${password}                  1234@Test
${msgCreatDepartmentSucess}  Cadastro realizado com sucesso.
${msgEditDepartmentSucess}   Cadastro atualizado com sucesso.
${msgEditStatusSucess}       Departamento inativado com sucesso!  
${msgCreatDepartmentError}   {'errors': ['No token provided.']}
${msgEditDepartmentError}    {'error': ["O campo 'diretoria' só pode conter letras e o caractere especial '&'."]}

*** Keywords ***

Criar Sessão
  ${headers}  Create Dictionary  accept=application/json  Content-Type=application/json
  Create Session    alias=APIAcademy    url=${url}   headers=${headers}

Logar Admin Departamento
  ${body}  Create Dictionary  mail=${mail}  password=${password}
  Log    ${body}
  Criar Sessão
  ${response_body}  POST on Session  alias=APIAcademy  url=/api/login/  json=${body}  expected_status=200
  Log    ${response_body.json()}
  Set Test Variable    ${TOKEN}  ${response_body.json()["token"]}

Criar uma Diretoria com sucesso no Departamento
  ${randon_boardName}  FakerLibrary.Language Name 
  ${body}  Create Dictionary  boardName=${randon_boardName}
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${create_board}  POST On Session  alias=APIAcademy  url=/api/board/  json=${body}  headers=${headers}  expected_status=201
  Log  ${create_board.json()}
  Set Test Variable    ${ID_BOARD}       ${create_board.json()["newBoard"]["_id"]}
  Set Test Variable    ${CREATE_BOARD}   ${create_board.json()}

Criar um Centro de Custo
  ${randon_costName}  FakerLibrary.Language Name
  ${body}  Create Dictionary  costCenterName=${randon_costName}  boardId=${ID_BOARD}
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${create_cost_center}  POST On Session  alias=APIAcademy  url=/api/costCenter/  json=${body}  headers=${headers}  expected_status=201
  Log  ${create_costCenter.json()}
  Set Test Variable    ${ID_COST_CENTER}       ${create_cost_center.json()["newCostCenter"]["_id"]}
  Set Test Variable    ${CREATE_COST_CENTER}   ${create_cost_center.json()}

Criar um Departamento com sucesso
  ${randon_departmentName}  FakerLibrary.Language Name
  ${body}  Create Dictionary  departmentName=${randon_departmentName}  costCenterId=${ID_COST_CENTER}
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${create_department}  POST On Session  alias=APIAcademy  url=/api/department/  json=${body}  headers=${headers}  expected_status=201
  Log  ${create_department.json()}
  Set Test Variable    ${ID_DEPARTMENT}  ${create_department.json()["newDepartment"]["_id"]}
  Set Test Variable    ${CREATE_DEPARTMENT}   ${create_department.json()}

Validar que o novo departamento foi cadastrado corretamente
  Log  ${CREATE_DEPARTMENT}
  Dictionary Should Contain Value    ${CREATE_DEPARTMENT}    ${msgCreatDepartmentSucess}

Criar um Departamento sem sucesso
  ${body}  Create Dictionary  boardName=Distt3d
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=
  ${create_departmentError}  POST On Session  alias=APIAcademy  url=/api/board/  json=${body}  headers=${headers}  expected_status=403
  Log  ${create_departmentError.json()}
  Set Test Variable    ${CREATE_DEPARTMENTERROR}   ${create_departmentError.json()}

Validar que o Departamento não foi cadastrado
  Log  ${CREATE_DEPARTMENTERROR}
  Should Be Equal As Strings   ${CREATE_DEPARTMENTERROR}  ${msgCreatDepartmentError}

Editar um Departamento com sucesso
  ${randon_editDepartmentName}  FakerLibrary.Language Name
  ${body}  Create Dictionary  departmentName=${randon_editDepartmentName}  costCenterId=${ID_COST_CENTER} 
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${edit_department}  PUT On Session  alias=APIAcademy  url=/api/department/${ID_DEPARTMENT}  json=${body}  headers=${headers}  expected_status=200
  Log  ${edit_department.json()}
  Set Test Variable    ${EDIT_DEPARTMENT}   ${edit_department.json()}

Validar que o Departamento foi alterado com sucesso
  Log  ${EDIT_DEPARTMENT}
  Dictionary Should Contain Value    ${EDIT_DEPARTMENT}    ${msgEditDepartmentSucess}

Editar um Departamento sem sucesso
  ${randon_editNameBoardError}  FakerLibrary.Email
  ${body}  Create Dictionary  boardName=${randon_editNameBoardError} 
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${edit_departmentError}  PUT On Session  alias=APIAcademy  url=/api/board/6617b9c7b190a884d43dc0dd  json=${body}  headers=${headers}  expected_status=400
  Log  ${edit_departmentError.json()}
  Set Test Variable    ${EDIT_DEPARTMENTERROR}   ${edit_departmentError.json()}

Validar que o Departamento não foi atualizado
  Log  ${EDIT_DEPARTMENTERROR}
  Should Be Equal As Strings    ${EDIT_DEPARTMENTERROR}    ${msgEditDepartmentError}

Listar Departamentos
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${list_department}  GET On Session  alias=APIAcademy  url=/api/department/  headers=${headers}  expected_status=200
  Log  ${list_department.json()}
  Set Test Variable    ${LIST_DEPARTMENT}   ${list_department.json()}

Pesquisar Departamentos
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${research_department}  GET On Session  alias=APIAcademy  url=/api/department/${ID_DEPARTMENT}  headers=${headers}  expected_status=200
  Log  ${research_department.json()}
  Set Test Variable    ${RESEARCH_DEPARTMENT}   ${research_department.json()}

Inativar um Departamento com sucesso
  ${body}  Create Dictionary  status=false 
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${status_department}  PUT On Session  alias=APIAcademy  url=/api/department/status/${ID_DEPARTMENT}  json=${body}  headers=${headers}  expected_status=202
  Log  ${status_department.json()}
  Set Test Variable    ${STATUS_DEPARTMENT}   ${status_department.json()}

Validar que o Departamento foi inativado
  Log  ${STATUS_DEPARTMENT}
  Dictionary Should Contain Value    ${STATUS_DEPARTMENT}    ${msgEditStatusSucess}