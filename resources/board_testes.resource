*** Settings ***
Library  RequestsLibrary
Library  String
Library  Collections   
Library  FakerLibrary    locale=pt_BR 

*** Variables ***
${url}                  https://chips.qacoders-academy.com.br
${mail}                 sysadmin@qacoders.com
${password}             1234@Test
${msgCreatBoardSucess}  Cadastro realizado com sucesso!
${msgEditBoardSucess}   Cadastro atualizado com sucesso.
${msgCreatBoardError}   {'errors': ['No token provided.']}
${msgEditBoardError}    {'error': ["O campo 'diretoria' só pode conter letras e o caractere especial '&'."]}
${msgResearchError}     Não foi possível encontrar a diretoria com o id especificado

*** Keywords ***
Criar Sessão
  ${headers}  Create Dictionary  accept=application/json  Content-Type=application/json
  Create Session    alias=APIAcademy    url=${url}   headers=${headers}

Logar Admin
  ${body}  Create Dictionary  mail=${mail}  password=${password}
  Log    ${body}
  Criar Sessão
  ${response_body}  POST on Session  alias=APIAcademy  url=/api/login/  json=${body}  expected_status=200
  Log    ${response_body.json()}
  Set Test Variable    ${TOKEN}  ${response_body.json()["token"]}

Validar o token e salvar em um header de autorização
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${response_body}  GET On Session  alias=APIAcademy  url=/api/validateToken  headers=${headers}
  Log  ${response_body.content}
  Log  ${TOKEN}

#Diretoria
Criar uma Diretoria com sucesso
  ${randon_boardName}  FakerLibrary.Language Name
  ${body}  Create Dictionary  boardName=${randon_boardName}
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${create_board}  POST On Session  alias=APIAcademy  url=/api/board/  json=${body}  headers=${headers}  expected_status=201
  Log  ${create_board.json()}
  Set Test Variable    ${ID_BOARD}       ${create_board.json()["newBoard"]["_id"]}
  Set Test Variable    ${CREATE_BOARD}   ${create_board.json()}

Validar que a nova diretoria foi cadastrada corretamente
  Log  ${CREATE_BOARD}
  Dictionary Should Contain Value    ${CREATE_BOARD}    ${msgCreatBoardSucess}

Criar uma Diretoria sem sucesso
  ${body}  Create Dictionary  boardName=Distt3d
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=
  ${create_boardError}  POST On Session  alias=APIAcademy  url=/api/board/  json=${body}  headers=${headers}  expected_status=403
  Log  ${create_boardError.json()}
  Set Test Variable    ${CREATE_BOARDERROR}   ${create_boardError.json()}

Validar que a nova diretoria não foi cadastrada
  Log  ${CREATE_BOARDERROR}
  Should Be Equal As Strings   ${CREATE_BOARDERROR}  ${msgCreatBoardError}

Editar uma Diretoria com sucesso
  ${randon_editNameBoard}  FakerLibrary.Language Name
  ${body}  Create Dictionary  boardName=${randon_editNameBoard}
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${edit_board}  PUT On Session  alias=APIAcademy  url=/api/board/${ID_BOARD}  json=${body}  headers=${headers}  expected_status=200
  Log  ${edit_board.json()}
  Set Test Variable    ${EDIT_BOARD}   ${edit_board.json()}

Validar que a Diretoria foi alterada com sucesso
  Log  ${EDIT_BOARD}
  Dictionary Should Contain Value    ${EDIT_BOARD}    ${msgEditBoardSucess}

Editar uma Diretoria sem sucesso
  ${randon_editNameBoardError}  FakerLibrary.Email
  ${body}  Create Dictionary  boardName=${randon_editNameBoardError} 
  Log  ${body}
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${edit_boardError}  PUT On Session  alias=APIAcademy  url=/api/board/6617b9c7b190a884d43dc0dd  json=${body}  headers=${headers}  expected_status=400
  Log  ${edit_boardError.json()}
  Set Test Variable    ${EDIT_BOARDERROR}   ${edit_boardError.json()}

Validar que a Diretoria não foi atualizada
  Log  ${EDIT_BOARDERROR}
  Should Be Equal As Strings    ${EDIT_BOARDERROR}    ${msgEditBoardError}

Listar Diretorias
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${list_board}  GET On Session  alias=APIAcademy  url=/api/board/  headers=${headers}  expected_status=200
  Log  ${list_board.json()}
  Set Test Variable    ${LIST_BOARD}   ${list_board.json()}

Pesquisar Diretoria
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${research_board}  GET On Session  alias=APIAcademy  url=/api/board/${ID_BOARD}  headers=${headers}  expected_status=200
  Log  ${research_board.json()}
  Set Test Variable    ${RESEARCH_BOARD}   ${research_board.json()}

Validar pesquisa de diretoria com sucesso
  Log  ${RESEARCH_BOARD}
  Should Be Equal As Strings   ${research_board["board"]["_id"]}   ${ID_BOARD}

Pesquisar Diretoria sem sucesso
  Criar Sessão
  ${headers}  Create Dictionary  Authorization=${TOKEN}
  ${research_board}  GET On Session  alias=APIAcademy  url=/api/board/6617b9c7b190a884d43dc0dd  headers=${headers}  expected_status=404
  Log  ${research_board.json()}
  Set Test Variable    ${RESEARCH_BOARD}   ${research_board.json()}

Validar pesquisa de diretoria sem sucesso
  Log ${RESEARCH_BOARD}
  Dictionary Should Contain Value    ${RESEARCH_BOARD}    ${msgResearchError} 