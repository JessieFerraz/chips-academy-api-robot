*** Settings ***
Resource  ../resources/board_testes.resource
Resource  ../resources/department_testes.resource

*** Variables ***

*** Test Cases ***
Cenário1: Diretoria
  Logar Admin
  Validar o token e salvar em um header de autorização
  Criar uma Diretoria com sucesso
  Validar que a nova diretoria foi cadastrada corretamente
  Criar uma Diretoria sem sucesso
  Validar que a nova diretoria não foi cadastrada
  Editar uma Diretoria com sucesso
  Validar que a Diretoria foi alterada com sucesso
  Editar uma Diretoria sem sucesso
  Validar que a Diretoria não foi atualizada
  Listar Diretorias
  Pesquisar Diretoria
  Validar pesquisa de diretoria com sucesso

Cenário2: Departamento
  Logar Admin Departamento
  Validar o token e salvar em um header de autorização
  Criar uma Diretoria com sucesso no Departamento
  Validar que a nova diretoria foi cadastrada corretamente
  Criar um Centro de Custo
  Criar um Departamento com sucesso
  Validar que o novo Departamento foi cadastrado corretamente
  Criar um Departamento sem sucesso
  Validar que o Departamento não foi cadastrado 
  Editar um Departamento com sucesso
  Validar que o Departamento foi alterado com sucesso
  Editar um Departamento sem sucesso
  Validar que o Departamento não foi atualizado 
  Listar Departamentos
  Pesquisar Departamentos
  Inativar um Departamento com sucesso
  Validar que o Departamento foi inativado
