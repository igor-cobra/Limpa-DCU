object dtmCnx: TdtmCnx
  Height = 321
  Width = 542
  object cnxDatabase: TFDConnection
    Params.Strings = (
      'Database=$(APPDATA)\Limpa DCU\database.db'
      'StringFormat=ANSI'
      'DateTimeFormat=DateTime'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 40
    Top = 16
  end
  object qryTabelaListaProj: TFDQuery
    Connection = cnxDatabase
    SQL.Strings = (
      'CREATE TABLE TBLCDSPROJ0 ('
      '    IDPROJETO INTEGER PRIMARY KEY AUTOINCREMENT,'
      '    NOMEPROJ TEXT NOT NULL,'
      '    CAMINHOPROJ TEXT NOT NULL'
      ');')
    Left = 40
    Top = 80
  end
  object qryDeleteProj: TFDQuery
    Connection = cnxDatabase
    SQL.Strings = (
      'DELETE FROM TBLCDSPROJ0'
      'WHERE IDPROJETO = :IDPROJETO;')
    Left = 40
    Top = 192
    ParamData = <
      item
        Name = 'IDPROJETO'
        DataType = ftInteger
        ParamType = ptInput
      end>
  end
  object qryCadastrarProj: TFDQuery
    Connection = cnxDatabase
    SQL.Strings = (
      'INSERT INTO TBLCDSPROJ0 (NOMEPROJ, CAMINHOPROJ)'
      'VALUES (:NOMEPROJ, :CAMINHOPROJ);'
      '')
    Left = 40
    Top = 248
    ParamData = <
      item
        Name = 'NOMEPROJ'
        DataType = ftString
        ParamType = ptInput
      end
      item
        Name = 'CAMINHOPROJ'
        DataType = ftString
        ParamType = ptInput
      end>
  end
  object qryListaProj: TFDQuery
    Connection = cnxDatabase
    SQL.Strings = (
      'SELECT'
      '   IDPROJETO,'
      '   CAST(NOMEPROJ AS VARCHAR(100)) AS NOMEPROJ,'
      '   CAST(CAMINHOPROJ AS VARCHAR(500)) AS CAMINHOPROJ'
      'FROM TBLCDSPROJ0'
      'ORDER BY'
      '   IDPROJETO')
    Left = 40
    Top = 136
    object qryListaProjIDPROJETO: TFDAutoIncField
      FieldName = 'IDPROJETO'
      Origin = 'IDPROJETO'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = True
    end
    object qryListaProjNOMEPROJ: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'NOMEPROJ'
      Origin = 'NOMEPROJ'
      ProviderFlags = []
      ReadOnly = True
      Size = 32767
    end
    object qryListaProjCAMINHOPROJ: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'CAMINHOPROJ'
      Origin = 'CAMINHOPROJ'
      ProviderFlags = []
      ReadOnly = True
      Size = 32767
    end
  end
end
