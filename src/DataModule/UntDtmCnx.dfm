object dtmCnx: TdtmCnx
  Height = 228
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
    Top = 88
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
